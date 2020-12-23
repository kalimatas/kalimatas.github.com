---
layout: post
title: "Gracefully terminate a program in Go"
description: "A description of an approach how to gracefully terminate a program in Go."
date: 2017-05-31 18:26
---

This post is about gracefully terminating a program without breaking currently running process.

Let's implement some dummy task to run.

{% highlight go %}
package main

import (
    "fmt"
    "time"
)

type Task struct {
    ticker *time.Ticker
}

func (t *Task) Run() {
    for {
        select {
        case <-t.ticker.C:
            handle()
        }
    }
}

func handle() {
    for i := 0; i < 5; i++ {
        fmt.Print("#")
        time.Sleep(time.Millisecond * 200)
    }
    fmt.Println()
}

func main() {
    task := &Task{
        ticker: time.NewTicker(time.Second * 2),
    }
    task.Run()
}
{% endhighlight %}

At two-second interval `Task.Run()` calls `handle()` function, which just prints five '**#**' symbols with 200ms delay.

If we terminate a running program by pressing Ctrl+C, while in the middle of the `handle()`, we'll be left with partly-done job.

{% highlight bash %}
$ go run main.go
#####
###^Csignal: interrupt
{% endhighlight %}

But we want our program to handle the interrupt signal gracefully, i.e. finish the currently running `handle()`, and, probably, perform some cleanup. First, let's capture the Ctrl+C. Notice, that we handle the receiving from channel `c` in another goroutine. Otherwise, the `select` construct would block the execution, and we would never get to creating and starting our `Task`.

{% highlight go %}
func main() {
    task := &Task{
        ticker: time.NewTicker(time.Second * 2),
    }

    c := make(chan os.Signal)
    signal.Notify(c, os.Interrupt)

    go func() {
        select {
        case sig := <-c:
            fmt.Printf("Got %s signal. Aborting...\n", sig)
            os.Exit(1)
        }
    }()

    task.Run()
}
{% endhighlight %}

Now, if we interrupt in the middle of `handle()`, we'll get this:

{% highlight bash %}
$ go run main.go
#####
##^CGot interrupt signal. Aborting...
exit status 1
{% endhighlight %}

Well, except that we see our message instead of a default one, nothing changed.

## Graceful exit

There is a pattern for a graceful exit, that utilises a channel.

{% highlight go %}
type Task struct {
    closed chan struct{}
    ticker *time.Ticker
}
{% endhighlight %}

The channel is used to tell all interested parties, that there is an intention to stop the execution of a `Task`. That's why it's called `closed`  by the way, but that's just a convention. The type of a channel doesn't matter, therefor usually it's `chan struct{}`. What matters is the fact of receiving a value from this channel. All long-running processes, that want to shut down gracefully, will, in addition to performing their actual job, listen for a value from this channel, and terminate, if there is one.

In our example, the long-running process is `Run()` function.

{% highlight go %}
func (t *Task) Run() {
    for {
        select {
        case <-t.closed:
            return
        case <-t.ticker.C:
            handle()
        }
    }
}
{% endhighlight %}

If we receive a value from `closed` channel, then we simply exit from `Run()` with `return`.

To express the intention to terminate the task we need to send some value to the channel. But we can do 
better. Since a receive from a closed channel returns the zero value immediately [^1], we can just close the 
channel.

{% highlight go %}
func (t *Task) Stop() {
    close(t.closed)
}
{% endhighlight %}

We call this function upon receiving a signal to interrupt. In order to close the channel, we first need to create it with `make`.

{% highlight go %}
func main() {
    task := &Task{
        closed: make(chan struct{}),
        ticker: time.NewTicker(time.Second * 2),
    }

    c := make(chan os.Signal)
    signal.Notify(c, os.Interrupt)

    go func() {
        select {
        case sig := <-c:
            fmt.Printf("Got %s signal. Aborting...\n", sig)
            task.Stop()
        }
    }()

    task.Run()
}
{% endhighlight %}

Let's try pressing Ctrl+C in the middle of `handle()` now.

{% highlight bash %}
$ go run main.go
#####
##^CGot interrupt signal. Aborting...
###
{% endhighlight %}

This works. Despite that we got an interrupt signal, the currently running `handle()` finished printing. 

## Waiting for a goroutine to finish

But there is a tricky part. This works, because `task.Run()` is called from the main goroutine, and handling of an interrupt signal happens in another. When the signal is caught, and the `task.Stop()` is called, this another goroutine dies, while the main goroutine continues to execute the `select` in `Run()`, receives a value from `t.closed` channel and returns.

What if we execute `task.Run()` not in the main goroutine? Like that.

{% highlight go %}
func main() {
    // previous code...

    go task.Run()

    select {
    case sig := <-c:
        fmt.Printf("Got %s signal. Aborting...\n", sig)
        task.Stop()
    }
}
{% endhighlight %}

If you interrupt the execution now, then currently running `handle()` will not finish, because the program will be terminated immediately. It happens, because when the interrupt signal is caught and processed, the main goroutine has nothing more to do - since the `task.Run()` is executed in another gourotine - and just exits. To fix this we need to somehow wait for the task to finish. This is where [sync.WaitGroup](https://golang.org/pkg/sync/#WaitGroup) will help us.

First, we associate a `WaitGroup` with our `Task`:

{% highlight go %}
type Task struct {
    closed chan struct{}
    wg     sync.WaitGroup
    ticker *time.Ticker
}
{% endhighlight %}

We instruct the `WaitGroup` to wait for one background process to finish, which is our `task.Run()`.

{% highlight go %}
func main() {
    // previous code...

    task.wg.Add(1)
    go func() { defer task.wg.Done(); task.Run() }()

    // other code...
}
{% endhighlight %}

Finally, we need to actually **wait** for the `task.Run()` to finish. This happens in `Stop()`:

{% highlight go %}
func (t *Task) Stop() {
    close(t.closed)
    t.wg.Wait()
}
{% endhighlight %}

The full code:

{% highlight go %}
package main

import (
	"fmt"
	"os"
	"os/signal"
	"sync"
	"time"
)

type Task struct {
	closed chan struct{}
	wg     sync.WaitGroup
	ticker *time.Ticker
}

func (t *Task) Run() {
	for {
		select {
		case <-t.closed:
			return
		case <-t.ticker.C:
			handle()
		}
	}
}

func (t *Task) Stop() {
	close(t.closed)
	t.wg.Wait()
}

func handle() {
	for i := 0; i < 5; i++ {
		fmt.Print("#")
		time.Sleep(time.Millisecond * 200)
	}
	fmt.Println()
}

func main() {
	task := &Task{
		closed: make(chan struct{}),
		ticker: time.NewTicker(time.Second * 2),
	}

	c := make(chan os.Signal)
	signal.Notify(c, os.Interrupt)

	task.wg.Add(1)
	go func() { defer task.wg.Done(); task.Run() }()

	select {
	case sig := <-c:
		fmt.Printf("Got %s signal. Aborting...\n", sig)
		task.Stop()
	}
}
{% endhighlight %}

*__Update__*: [Ahmet Alp Balkan](https://github.com/ahmetb) pointed out, that the pattern used in this post is more error-prone and, probably, should not be used in favor of a pattern with [context](https://golang.org/pkg/context/) package. For details, read [Make Ctrl+C cancel the context.Context](https://medium.com/@matryer/make-ctrl-c-cancel-the-context-context-bd006a8ad6ff).

## Notes

[^1]: <a href="https://dave.cheney.net/2014/03/19/channel-axioms">Channel Axioms</a>

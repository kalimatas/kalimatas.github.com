---
layout: post
title: "Building a Slack command with Go"
description: A step by step tutorial on how to create a Slack command with Go and deploy it to Heroku
date: 2017-09-10 17:06
---

This post is a step by step tutorial on how to build a simple Slack command with Go.

* [So, what are we going to build?](#intro)
* [Anatomy of a Slack command](#overview)
* [Local development with ngrok](#local-dev)
* [Slack application and command](#slack-app)
* [Source code overview](#code)
* [Running the app with Docker](#docker)
* [Deploying the app to Heroku](#heroku)

### <a name="intro"></a> <a name="overview"></a> So, what are we going to build?

By the end of the tutorial, we'll have `cowsay <message>` command, that formats the message in the same way as it's Linux counterpart. It actually uses the Linux's utility to do the job, so it basically just a wrapper with HTTP interface. The final result will look like that:

{: .center}
![Example message](/static/img/posts/cowsay_final_result.png "Example message")

### <a name="overview"></a> Anatomy of a Slack command

Before going into the implementation, let's have a look at how Slack commands work, what we need to implement, and how all the parts will communicate with each other.

*todo: diagram of communication* 

### <a name="local-dev"></a> Local development with ngrok

As you can see from the diagram above, in order for our command to operate, Slack needs to send a POST HTTP request to some endpoint, which means that our application should be available on the Internet. This is not a problem once the application is deployed somewhere. But during the development phase we need our local instance be available for Slack. This can be done with [ngrok](https://ngrok.com). It let's you expose a local server to the Internet. Once started, it will provide you with a publicly available URL of your local server.

So, [download and install](https://ngrok.com/download) ngrok first. Then run it:

{% highlight bash %}
$ ngrok http 8080
{% endhighlight %}

Here we tell ngrok, that our server is running on port `8080` (not yet actually, but it will). If everything is OK, you'll see a similar output:

{% highlight bash %}
ngrok by @inconshreveable                                 (Ctrl+C to quit)

Session Status                online
Version                       2.2.8
Region                        United States (us)
Web Interface                 http://127.0.0.1:4040
Forwarding                    http://502a662f.ngrok.io -> localhost:8080
Forwarding                    https://502a662f.ngrok.io -> localhost:8080

Connections                   ttl     opn     rt1     rt5     p50     p90
                              1       0       0.00    0.00    0.42    0.42

HTTP Requests
-------------
{% endhighlight %}

Pay attention to the URL, `https://502a662f.ngrok.io`, in `Forwarding` section: we'll need to specify it in our Slack command configuration interface later.

Also, this URL is temporary, meaning that if you stop ngrok now (or close a terminal window, for example), on the next start you'll get another URL. So, leave a terminal window with ngrok open for the duration of the tutorial.

### <a name="slack-app"></a> Slack application and command

It's time to do some clicky-clicky thingy: we need to create in Slack a workspace, an application, and a command. Go to [create](https://slack.com/create) page and follow the instruction to register and create a new workspace.

After you're done, go to [the list of your applications](https://api.slack.com/apps) and hit `Create New App`. There you have to specify your app name (doesn't really matter) and select, which development workspace this app should be created in. ~~Choose wisely!~~ Choose your newly created workspace. For me it looks like this:

{: .center}
![Create a Slack app](/static/img/posts/create_a_slack_app.png "Create a Slack app")

Now go to the application settings. Here you can configure all aspects of the application, for example, change icon under `Display information`. For us, the most interested part now is under `App Credentials`, where you can find a `Verification Token`:

{: .center}
![App credentials](/static/img/posts/app_credentials.png "App credentials")

This token is used to verify, that HTTP requests to our server are actually coming from Slack. We'll use it later in our source code.

The final step in Slack administration interface is to create a slash command. While you're in the application setting, hit the `Slash Commands` in the left menu and then `Create New Command`. Here is what we need to enter:

{: .center}
![Create a slash command](/static/img/posts/create_slash_command.png "Create a slash command")

Pay attention here to the `Request URL`: this is the URL provided us by ngrok from [Local development with ngrok](#local-dev) step.

### <a name="code"></a> Source code overview

Finally. It's time for source code. In essence, our application is just a wrapper around `cowsay` utility with HTTP interface. It accepts POST requests and returns formatted text back. Full source code can be found in [the GitHub repository](https://github.com/kalimatas/slack-cowbot). 

Let's review the startup procedure:

{% highlight go %}
var (
	port  string = "80"
	token string
)

func init() {
	token = os.Getenv("COWSAY_TOKEN")
	if "" == token {
		panic("COWSAY_TOKEN is not set!")
	}

	if "" != os.Getenv("PORT") {
		port = os.Getenv("PORT")
	}
}

func main() {
	http.HandleFunc("/", cowHandler)
	log.Fatalln(http.ListenAndServe(":"+port, nil))
}
{% endhighlight %}

By default, the server will listen on port 80, but it can be changed by setting the `PORT` environment variable. The name of the variable is not random - this is a [requirement](https://devcenter.heroku.com/articles/container-registry-and-runtime#dockerfile-commands-and-runtime) from Heroku. The `COWSAY_TOKEN` must be set. This is a `Verification Token` from the [Slack application and command](#slack-app) step. It's a secret value, that's why we don't put it to any configuration file. The alternative would be to pass it as an argument, but keeping secrets in environmental variables is a [common practice](https://12factor.net/config).

Now, let's have a look at the `cowHandler` function:

{% highlight go %}
func cowHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != "POST" {
		http.Error(w, http.StatusText(http.StatusMethodNotAllowed), http.StatusMethodNotAllowed)
		return
	}

	if token != r.FormValue("token") {
		http.Error(w, http.StatusText(http.StatusUnauthorized), http.StatusUnauthorized)
		return
	}

	text := strings.Replace(r.FormValue("text"), "\r", "", -1)
	balloonWithCow, err := sc.Cowsay(text)
	if err != nil {
		log.Println(err)
		http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
		return
	}

	jsonResp, _ := json.Marshal(struct {
		Type string `json:"response_type"`
		Text string `json:"text"`
	}{
		Type: "in_channel",
		Text: fmt.Sprintf("```%s```", balloonWithCow),
	})

	w.Header().Add("Content-Type", "application/json")
	fmt.Fprintf(w, string(jsonResp))
}
{% endhighlight %}

Here is what's going on:

1. We allow only POST requests. Everything else will result in 405 HTTP error.
2. We validate that requests come from Slack by checking the `token`. It must be equal to what we set in `COWSAY_TOKEN`.
3. The main job is done by `sc.Cowsay(text)`: it wraps the text from the request with `cowsay` utility. We'll get to it later.
4. We prepare the response and return it as a JSON string. The response object in our case has two keys: `response_type` and `text`. The `text` is, well, the response text. The `response_type: "in_channel"` tells a Slack client to show the response from the command to everyone in the channel. Otherwise, only the one who issued the command would see the response (it's called *Ephemeral* response). Read more about it [here](https://api.slack.com/slash-commands#responding_to_a_command).

### <a name="docker"></a> Running the app with Docker

Docker

### <a name="heroku"></a> Deploying the app to Heroku

Heroku

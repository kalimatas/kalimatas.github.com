---
title: Playing music with Python
layout: post
description: Python, music
date: 2012-08-17
hhlink: http://news.ycombinator.com/item?id=4398570
---

Wand to play a sound in Python but don't know how? <strike>It's your problem</strike> No problems. I'll show you some ways. Here is the list of popular Python libraries used to make noise with short descriptions and usage examples.

### [Pyglet](http://www.pyglet.org/)

A cross-platform windowing and multimedia library for Python. Among it's features: no external dependencies or installation requirements; can optionally use [AVbin](http://code.google.com/p/avbin/) to play back audio formats such as MP3, OGG/Vorbis and WMA. Distributed under BSD open-source license.

{% highlight python %}
#!/usr/bin/env python
import pyglet
song = pyglet.media.load('thesong.ogg')
song.play()
pyglet.app.run()
{% endhighlight %}

### [Pygame](http://www.pygame.org)

Pygame is a set of Python modules designed for writing games. Pygame adds functionality on top of the excellent [SDL](http://www.libsdl.org/) library. This allows you to create fully featured games and multimedia programs in the python language. Pygame is highly portable and runs on nearly every platform and operating system. Pygame itself has been downloaded millions of times, and has had millions of visits to its website. Distributed under GPL.

{% highlight python %}
#!/usr/bin/env python
import pygame
pygame.init()
song = pygame.mixer.Sound('thesong.ogg')
clock = pygame.time.Clock()
song.play()
while True:
    clock.tick(60)
pygame.quit()
{% endhighlight %}

### [GStreamer Python Bindings](http://pygstdocs.berlios.de/)

GStreamer is a pipeline-based multimedia framework written in the C programming language with the type system based on [GObject](http://en.wikipedia.org/wiki/GObject).

GStreamer allows a programmer to create a variety of media-handling components, including simple audio playback, audio and video playback, recording, streaming and editing. The pipeline design serves as a base to create many types of multimedia applications such asvideo editors, streaming media broadcasters and media players. Distributed under LGPL.

{% highlight python %}
#!/usr/bin/env python
import pygst
pygst.require('0.10')
import gst
import gobject
import os

mainloop = gobject.MainLoop()
pl = gst.element_factory_make("playbin", "player")
pl.set_property('uri','file://'+os.path.abspath('thesong.ogg'))
pl.set_state(gst.STATE_PLAYING)
mainloop.run()
{% endhighlight %}

### [PyAudio](http://people.csail.mit.edu/hubert/pyaudio/)

PyAudio provides Python bindings for [PortAudio](http://www.portaudio.com/), the cross-platform audio I/O library. With PyAudio, you can easily use Python to play and record audio on a variety of platforms.

PyAudio is still super-duper alpha quality. It has run on GNU/Linux 2.6, Microsoft Windows 7/XP, and Apple Mac OS X 10.5+—but it could use more testing.

I couldn't get how to play ogg files, here is an example for wav.

{% highlight python %}
#!/usr/bin/env python
import pyaudio
import wave

chunk = 1024
wf = wave.open('thesong.wav', 'rb')
p = pyaudio.PyAudio()

stream = p.open(
    format = p.get_format_from_width(wf.getsampwidth()),
    channels = wf.getnchannels(),
    rate = wf.getframerate(),
    output = True)
data = wf.readframes(chunk)

while data != '':
    stream.write(data)
    data = wf.readframes(chunk)

stream.close()
p.terminate()
{% endhighlight %}

### [PyMedia](http://pymedia.org/tut/)

PyMedia is a Python module for wav, mp3, ogg, avi, divx, dvd, cdda etc files manipulations. It allows you to parse, demutiplex, multiplex, decode and encode all supported formats. It can be compiled for Windows, Linux and cygwin.

{% highlight python %}
#!/usr/bin/env python
import pymedia.audio.acodec as acodec
import pymedia.audio.sound as sound
import pymedia.muxer as muxer

file_name = 'thesong.ogg'
dm = muxer.Demuxer(str.split(file_name, '.')[-1].lower())
f = open(file_name, 'rb')
snd = dec = None
s = f.read( 32000 )
while len(s):
    frames = dm.parse(s)
    if frames:
        for fr in frames:
            if dec == None:
                dec = acodec.Decoder(dm.streams[fr[0]])

            r = dec.decode(fr[1])
            if r and r.data:
                if snd == None:
                    snd = sound.Output(
                        int(r.sample_rate),
                        r.channels,
                        sound.AFMT_S16_LE)
                data = r.data
                snd.play(data)
    s = f.read(512)

while snd.isPlaying():
time.sleep(.05)
{% endhighlight %}

Looks like Pyglet is the obvious choise.
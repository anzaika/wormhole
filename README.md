# WebRTC Wormhole

## About

This an educational project meant to demonstrate how you can
integrate WebRTC in a Phoenix app. It's meant to be
as simple as possible, yet be able to establish a video
call between two users through space, networks and NATs =)

This app would not have been possible without all the hard work done by people behind 
WebRTC, [Membrane framework](https://membrane.stream/) and 
[Membrane RTC Engine](https://github.com/jellyfish-dev/membrane_rtc_engine).
Many thanks to all the people involved.

Membrane RTC engine has a beautiful project called 
[Membrane Videoroom](https://github.com/membraneframework/membrane_videoroom) 
to demonstrate the capabilities of their library and you should definitely check it out.

Yet, I found the Membrane Videoroom too complicated. I needed something
much simpler to figure out the inner workings of the underlying software. 

> Perfection is achieved, not when there is nothing more to add, but when there is nothing left to take away.
>
> ― Antoine de Saint-Exupéry

Objectives:

- Use Phoenix 1.7
- Peers communicate through LiveView
- Works when deployed on Fly.io
- Works for peers in mobile networks (infamous for layered NAT configs)

Limitations:

- No persistence
- A single "room" for all clients
- No more than two peers
- Not handling any errors, only the 'happy path'
- Not even handling peer disconnections

## Run it yourself

Running this app locally can actually be much harder that just launching
it on the server.

Start by cloning the repository and running `fly launch`.
You won't need a database or Redis for this app, so you can safely skip it.
And after that:

- rename `fly.toml` -> `fly.toml.orig`
- rename `fly.toml.template` -> `fly.toml`
- use values from `fly.toml.orig` to fill up the `TODO:` values in `fly.toml`
- `fly deploy`

Now open your app in the browser on two different devices. It should work 🤞


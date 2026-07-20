---
title: '"X-" HTTP Headers'
date: 2026-07-20T00:00:59-07:00
draft: false
summary: ""
description: ""
tags: []
showHero: true
---
I've noticed some HTTP Headers prefixed with "x-" but never bothered to look up what this convention meant until now. I figured it was something about "external" or to denote a header concerning more than one application/endpoint. For instance, [X-Forwarded-For](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/X-Forwarded-For), which is typically used to communicate the original client IP address before a request is forwarded by a reverse proxy.

This article was an interesting source: https://inspiredmonks.com/what-does-x-mean-in-http-headers/

This unofficially stands for "experimental" or "extension" and was originally supposed to be used for anything which wasn't a [standard HTTP header](https://en.wikipedia.org/wiki/List_of_HTTP_header_fields#Standard_request_fields), like `Content-Length`.

The "X-" prefix was deprecated by IETF in RFC 6648 (June 2012), but this doesn't mandate anything about new or existing protocols.

>Makes no recommendation as to whether existing "X-" parameters
   ought to remain in use or be migrated to a format without the
   "X-"; this is a matter for the creators or maintainers of those
   parameters.

Somewhat unrelated, I found it very satisfying that certain keywords are used consistently in RFCs and [each have their own definitions](https://www.rfc-editor.org/info/rfc2119/).
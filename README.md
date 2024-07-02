## GCP Hijack

In the previous red team operation, we found it's painful to manually change the local GCP identity.

> This is a tool written for professional red teams. It help you to change your local GCP identity to victim identity. It requires victim's credentials.db file & active gcp project info.

## How to use it?

```
$ git clone git@github.com:benjiamin911/GCPHijack.git
$ ./GCPHijack/hijack.sh

credentials.db path: <put the credentials.db file path here>
default project: <put the default project name here>
```

## Contributing

Shout out to @mandatoryprogrammer

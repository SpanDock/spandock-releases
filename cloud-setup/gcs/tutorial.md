# Set up Google Cloud Storage for SpanDock

This creates a private bucket, a service account that can only use objects
in that bucket (`roles/storage.objectAdmin` on the bucket), and an HMAC key
for it. SpanDock talks to Cloud Storage through its S3-compatible XML API,
so no service account JSON file is needed.

Nothing here is sent to SpanDock: you paste the values into SpanDock
yourself.

## Choose the project

Pick the project the bucket goes in:

```sh
gcloud config set project PROJECT_ID
```

If Cloud Shell asks you to authorize gcloud, accept (or run
`gcloud auth login`).

## Create the bucket, service account and key

Run the command SpanDock showed you, with the bucket name it suggested (or
your own) and optionally a location (default `US`):

```sh
bash setup.sh BUCKET_NAME US
```

## Paste the values into SpanDock

Back in SpanDock (Settings → Scaling → Object storage → Connect a bucket,
provider Google Cloud Storage), enter the bucket, the HMAC access ID and
the HMAC secret, then Connect. SpanDock tests the bucket right away.

The secret is shown only once: copy it, then clear the terminal (`clear`).

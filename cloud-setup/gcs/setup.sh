#!/usr/bin/env bash
# SpanDock object storage on Google Cloud Storage, for Cloud Shell (or any
# shell with gcloud signed in): a private bucket, a service account with
# roles/storage.objectAdmin on that bucket only, and an HMAC key for it
# (SpanDock uses Cloud Storage's S3-compatible XML API). Prints the values
# to paste into SpanDock (Settings → Scaling → Object storage).
#
#   bash setup.sh <bucket> [location] [project]
#
# Source of truth: SpanDock's packaging/cloud-setup/gcs/ (copied to
# SpanDock/spandock-releases cloud-setup/gcs/).
set -euo pipefail

BUCKET="${1:?usage: setup.sh <bucket> [location] [project]}"
LOCATION="${2:-US}"
PROJECT="${3:-$(gcloud config get-value project 2>/dev/null || true)}"
if [ -z "$PROJECT" ]; then
  echo "Choose a project first: gcloud config set project <project ID>" >&2
  exit 1
fi
SA_NAME="spandock-storage"
SA="${SA_NAME}@${PROJECT}.iam.gserviceaccount.com"

echo "Creating the bucket gs://${BUCKET} in ${LOCATION} (project ${PROJECT})..."
gcloud storage buckets create "gs://${BUCKET}" --project="$PROJECT" --location="$LOCATION" \
  --uniform-bucket-level-access --public-access-prevention

if ! gcloud iam service-accounts describe "$SA" --project="$PROJECT" >/dev/null 2>&1; then
  echo "Creating the service account ${SA}..."
  gcloud iam service-accounts create "$SA_NAME" --project="$PROJECT" \
    --display-name="SpanDock object storage"
fi

echo "Granting it roles/storage.objectAdmin on gs://${BUCKET} only..."
gcloud storage buckets add-iam-policy-binding "gs://${BUCKET}" \
  --member="serviceAccount:${SA}" --role=roles/storage.objectAdmin >/dev/null

echo "Creating an HMAC key for it..."
read -r ACCESS_ID SECRET < <(gcloud storage hmac create "$SA" --project="$PROJECT" \
  --format='value(metadata.accessId,secret)')

cat <<OUT

Done. Paste these into SpanDock:
  Bucket             ${BUCKET}
  HMAC access ID     ${ACCESS_ID}
  HMAC secret        ${SECRET}

The secret is shown only here: copy it now, then clear this terminal.
OUT

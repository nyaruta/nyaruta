#!/usr/bin/env bash

# Original: https://github.com/b1n23/acme.sh/blob/2f5ea120cb18d56d9d21da07034cb679457b3c94/deploy/netlify.sh
# Script to deploy certificate to Netlify
# https://docs.netlify.com/api/get-started/#authentication
# https://open-api.netlify.com/#tag/sniCertificate

# This deployment required following variables
# export Netlify_ACCESS_TOKEN="Your Netlify Access Token"
# export Netlify_SITE_ID="Your Netlify Site ID"
# export CERT_FILE_PATH="/path/to/certificate.crt"
# export KEY_FILE_PATH="/path/to/private.key"
# export CA_FILE_PATH="/path/to/ca.crt"

# If have more than one SITE ID
# export Netlify_SITE_ID="SITE_ID_1 SITE_ID_2"

# returns 0 means success, otherwise error.

########  Public functions #####################

#keyfile certfile cafile
netlify_deploy() {
  _ckey="${KEY_FILE_PATH:-$1}"
  _ccert="${CERT_FILE_PATH:-$2}"
  _cca="${CA_FILE_PATH:-$3}"

  if [ -z "$ACCESS_TOKEN" ]; then
    echo "ACCESS_TOKEN is not defined."
    return 1
  fi
  if [ -z "$SITE_IDS" ]; then
    echo "SITE_IDS is not defined."
    return 1
  fi
  
  if [ ! -f "$_ckey" ]; then
    echo "Private key file not found: $_ckey"
    return 1
  fi
  if [ ! -f "$_ccert" ]; then
    echo "Certificate file not found: $_ccert"
    return 1
  fi
  if [ ! -f "$_cca" ]; then
    echo "CA certificate file not found: $_cca"
    return 1
  fi

  echo "Deploying certificate to Netlify..."
  echo "Using certificate: $_ccert"
  echo "Using private key: $_ckey"
  echo "Using CA certificate: $_cca"

  ## upload certificate
  string_ccert=$(awk '{printf "%s\\n", $0}' "$_ccert")
  string_cca=$(awk '{printf "%s\\n", $0}' "$_cca")
  string_key=$(awk '{printf "%s\\n", $0}' "$_ckey")


  for SITE_ID in $SITE_IDS; do
    _request_body="{\"certificate\":\"$string_ccert\",\"key\":\"$string_key\",\"ca_certificates\":\"$string_cca\"}"
    _response=$(curl -s -X POST "https://api.netlify.com/api/v1/sites/$SITE_ID/ssl" \
      -H "Authorization: Bearer $ACCESS_TOKEN" \
      -H "Content-Type: application/json" \
      --data "$_request_body")

    if [[ "$_response" =~ \"error\" ]]; then
      echo "Error in deploying certificate to Netlify SITE_ID $SITE_ID."
      echo "$_response"
      return 1
    fi
    echo "Certificate successfully deployed to Netlify SITE_ID $SITE_ID."
  done

  return 0
}

netlify_deploy $1 $2 $3
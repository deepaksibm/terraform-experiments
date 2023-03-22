
#!/bin/sh

JQ=/usr/bin/jq
curl https://stedolan.github.io/jq/download/linux64/jq > $JQ && chmod +x $JQ
instance_identity_token=`curl -X PUT "http://169.254.169.254/instance_identity/v1/token?version=2022-04-26" -H "Metadata-Flavor: ibm" -H "Accept: application/json" -d '{ "expires_in": 300 }' | jq -r '(.access_token)'`
instance_crn=`curl -X GET "http://169.254.169.254/metadata/v1/instance?version=2022-04-26" -H "Authorization: Bearer $instance_identity_token" | jq -r '(.crn)'`
iam_token_req='{"trusted_profile": {"id": "'${trustedprofile}'"}}'
iam_token=`curl -X POST "http://169.254.169.254/instance_identity/v1/iam_token?version=2022-04-26" -H "Metadata-Flavor: ibm" -H "Accept: application/json" -H "Authorization: Bearer $instance_identity_token" -d "$iam_token_req" | jq -r '(.access_token)'`
tag_attach_req='{"resources": [{ "resource_id": "'$instance_crn'" }], "tag_names": ["initdone"] }'
response=`curl -X POST "https://tags.global-search-tagging.cloud.ibm.com/v3/tags/attach" -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization: Bearer $iam_token" -d "$tag_attach_req"`
echo $response

#!/bin/bash
keyid="$1"
secretkey="$2"
ACCOUNT_ID="$3"

API_URL="https://api.ksoc.com"

authbody="{\"access_key_id\":\"$keyid\",\"secret_key\":\"$secretkey\"}"
#get api token
token=$(curl --connect-timeout 5  --max-time 10  --retry 5  --retry-delay 0  --retry-max-time 40 'https://api.ksoc.com/authentication/authenticate' -d "$authbody"|jq ' .token')
token=`echo $token | sed 's/\"//g'`

#get 1000 images for account
#if there are more than 1000 images change page_size=1000 below
IMAGE=$(curl --connect-timeout 5  --max-time 10  --retry 5  --retry-delay 0  --retry-max-time 40 -s --header "Authorization: Bearer ${token}" "${API_URL}/accounts/${ACCOUNT_ID}/images?page_size=1000")

#extract each image digest, name and scan_id
IMAGE_DIGESTS=$(echo $IMAGE | jq -r '.entries[] | "\(.digest)	\(.name)	\(.scan_id)"')

#loop and download each image's:
#1) sbom
#2) associated resources/workloads
#3) clusters
while read -r line
do
    DIGEST=$(echo "$line" | awk -v FS='\t' -v OFS='\t' '{print $1;}')
    NAME=$(echo "$line" | awk -v FS='\t' -v OFS='\t' '{print $2;}')
    SCANID=$(echo "$line" | awk -v FS='\t' -v OFS='\t' '{print $3;}')
    echo "Downloading sbom for: $NAME"

    #download the image sbom 
    #{ACCOUNT_ID}-${NAME}-${DIGEST}.sbom
    curl --connect-timeout 5  --max-time 10  --retry 5  --retry-delay 0  --retry-max-time 40 -s --header "Authorization: Bearer ${token}" "${API_URL}/accounts/${ACCOUNT_ID}/sboms/${DIGEST}/download" -o "${ACCOUNT_ID}-${NAME}-${DIGEST}.sbom"

    #get image data
    IMAGEDETAILS=$(curl --connect-timeout 5  --max-time 10  --retry 5  --retry-delay 0  --retry-max-time 40 -s --header "Authorization: Bearer ${token}" "${API_URL}/accounts/${ACCOUNT_ID}/images/${DIGEST}/scans/${SCANID}")
    IMAGEDETAILS_DATA=$(echo $IMAGEDETAILS | jq -r '"\(.name)	\(.repo)	\(.tags)"')

    #get image resources
    ACCOUNT_RESOURCES=$(curl --connect-timeout 5  --max-time 10  --retry 5  --retry-delay 0  --retry-max-time 40 -s --header "Authorization: Bearer ${token}" "${API_URL}/accounts/${ACCOUNT_ID}/resources?image_digest=${DIGEST}")
    ACCOUNT_RESOURCES_DATA=$(echo $ACCOUNT_RESOURCES | jq -r '.entries[] | "\(.name)	\(.kind)	\(.namespace)	\(.cluster_id)"')

    #get image clusters
    IMAGECLUSTERS=$(curl --connect-timeout 5  --max-time 10  --retry 5  --retry-delay 0  --retry-max-time 40 -s --header "Authorization: Bearer ${token}" "${API_URL}/accounts/${ACCOUNT_ID}/images/${DIGEST}/clusters")
    IMAGECLUSTERS_DATA=$(echo $IMAGECLUSTERS | jq -r '.entries[] | "\(.id)	\(.name)"')

    #write image's data
    #name, repo, and tags (e.g. version number)
    #${ACCOUNT_ID}-${NAME}-${DIGEST}.sbom.image.data
    echo "$IMAGEDETAILS_DATA"  > "${ACCOUNT_ID}-${NAME}-${DIGEST}.sbom.image.data"

    #write image's resources data
    #name, kind, namespaces, and cluster id
    #${ACCOUNT_ID}-${NAME}-${DIGEST}.sbom.resource.data
    echo "$ACCOUNT_RESOURCES_DATA" > "${ACCOUNT_ID}-${NAME}-${DIGEST}.sbom.resource.data"

    #write image's cluster data
    #id, name
    #${ACCOUNT_ID}-${NAME}-${DIGEST}.sbom.cluster.data
    echo "$IMAGECLUSTERS_DATA" > "${ACCOUNT_ID}-${NAME}-${DIGEST}.sbom.cluster.data" 

done < <(printf '%s\n' "$IMAGE_DIGESTS")


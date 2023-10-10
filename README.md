# sbom-search
Search your KSOC image SBOMs in multiple accounts for a specific package name.

## How to download SBOM data
In each KSOC account you want to search, create an API token in Settings>API Tokens.
Take note of the Access Key and Secret Access Key. You will also need the Account ID which can be found in the browser address bar.\
`https://app.ksoc.com/{TENANTID}/accounts/{ACCOUNTID}`

Add on entry for each account in the file `allaccounts.sh`\
`./sbom.sh {accessKeyId1} {secretKeyId1} {accountId1}`\
`./sbom.sh {accessKeyId2} {secretKeyId2} {accountId2}`

Then run `./allaccounts.sh`.  For each account in `allaccounts.sh`, all the image SBOMs will be downloaded in a file in the local folder along with supporting files that contain the image data, a list of image resources, and list of image clusters.\

The file names are:\
`{ACCOUNT_ID}-{NAME}-{DIGEST}.sbom`\
`{ACCOUNT_ID}-{NAME}-{DIGEST}.sbom.cluster.data`\
`{ACCOUNT_ID}-{NAME}-{DIGEST}.sbom.images.data`\
`{ACCOUNT_ID}-{NAME}-{DIGEST}.sbom.resource.data`

## How to search for packages in downloaded image SBOMs
Run `search.sh` and include one package name as a parameter.

Example:\
`search.sh curl`

All the SBOMs will be searched and results will be seen in STOUT.

You can output the data to a CSV by redirecting STOUT.

Example:\
`search.sh curl > search_curl.csv`

Output includes the following:
- imagename
- imagesource
- imageversion
- packagename
- packageversion
- workloadname
- workloadtype
- workloadnamespace
- workloadcluster

## Output
Example output below for `curl`:

| imagename  | imagesource                    | imageversion | packagename | packageversion    | workloadname                              | workloadtype | workloadnamespace | workloadcluster   |
| ---------- | ------------------------------ | ------------ | ----------- | ----------------- | ----------------------------------------- | ------------ | ----------------- | ----------------- |
| controller | registry.k8s.io/ingress-nginx/ | ["v1.6.4"]   | curl        | 7.87.0-r1         | ingress-nginx-controller-86cb994656-7nf26 | Pod          | ingress-nginx     | SFO3 PRD          |
| controller | registry.k8s.io/ingress-nginx/ | ["v1.6.4"]   | curl        | 7.87.0-r1         | ingress-nginx-controller-86cb994656-j68rk | Pod          | ingress-nginx     | SFO3 PRD          |
| controller | registry.k8s.io/ingress-nginx/ | ["v1.6.4"]   | curl        | 7.87.0-r1         | ingress-nginx-controller-86cb994656-pbddb | Pod          | ingress-nginx     | NYC1 PRD          |
| controller | registry.k8s.io/ingress-nginx/ | ["v1.6.4"]   | curl        | 7.87.0-r1         | ingress-nginx-controller-86cb994656-xmmj9 | Pod          | ingress-nginx     | NYC1 PRD          |
| controller | registry.k8s.io/ingress-nginx/ | ["v1.8.2"]   | curl        | 8.2.1-r0          | ingress-nginx-controller-5dcc7dbd55-vf74z | Pod          | kube-system       | EKS US-West-2 PRD |
| cpbridge   | docker.io/digitalocean/        | ["1.25.1"]   | curl        | 7.88.1-10+deb12u1 | cpc-bridge-proxy-2wk7r                    | Pod          | kube-system       | Honeypot          |
| cpbridge   | docker.io/digitalocean/        | ["1.25.1"]   | curl        | 7.88.1-10+deb12u1 | cpc-bridge-proxy-58dbp                    | Pod          | kube-system       | NYC1 PRD          |
| cpbridge   | docker.io/digitalocean/        | ["1.25.1"]   | curl        | 7.88.1-10+deb12u1 | cpc-bridge-proxy-9hzrd                    | Pod          | kube-system       | Honeypot          |
| cpbridge   | docker.io/digitalocean/        | ["1.25.1"]   | curl        | 7.88.1-10+deb12u1 | cpc-bridge-proxy-bw6dn                    | Pod          | kube-system       | SFO3 PRD          |
| cpbridge   | docker.io/digitalocean/        | ["1.25.1"]   | curl        | 7.88.1-10+deb12u1 | cpc-bridge-proxy-mgszs                    | Pod          | kube-system       | SFO3 PRD          |



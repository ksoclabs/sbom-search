#!/bin/bash
#search for literal package name in all sboms in the current folder
#./search.sh {packageName}
#the results will go to STOUT but can be redirected to a CSV file
#./search.sh {packageName} > search_curl.csv
package="$1"

regex="\"name\":\"$package\",\"[^,]*,\"versionInfo\":\"[^\"]*"

#these are the CSV headers
echo "imagename,imagesource,imageversion,packagename,packageversion,workloadname,workloadtype,workloadnamespace,workloadcluster"

#look through each *.sbom file in the folder
for i in *.sbom; do
    [ -f "$i" ] || break

    #filter for any packages in the sbom that match the search package
    found=$(jq -c . ${i} | grep -oh ${regex}) 
    if [ "$found" != "" ]
    then
      #when a matching package is found, store the package name and version
      packagename=$(echo "$found" | sed -nr 's/"name\":\"([^\\"]*).*/\1/p')
      packageversion=$(echo "$found" | sed -nr 's/.*"versionInfo\":\"([^\"]*).*/\1/p')
      
      #load the image data from the image's sbom.image.data file
      #this will be the prefix for the matching output entry
      IMAGEDATA=$(cat "$i".image.data)

      #echo "$packagename"
      #echo "$packageversion"

      #read each line of the image's sbom.resource.data
      while read p; do
        #extract workload name, type, namespace, and clusterid
        WORKLOADNAME=$(echo "$p" | awk -v FS='\t' -v OFS='\t' '{print $1;}')
        WORKLOADTYPE=$(echo "$p" | awk -v FS='\t' -v OFS='\t' '{print $2;}')
        WORKLOADNAMESPACE=$(echo "$p" | awk -v FS='\t' -v OFS='\t' '{print $3;}')
        WORKLOADCLUSTERID=$(echo "$p" | awk -v FS='\t' -v OFS='\t' '{print $4;}')

        #read each line of the image's sbom.cluster.data
        while read c; do
          #extract the cluster id and name
          CLUSTERID=$(echo "$c" | awk -v FS='\t' -v OFS='\t' '{print $1;}')
          CLUSTERNAME=$(echo "$c" | awk -v FS='\t' -v OFS='\t' '{print $2;}')

          #match the cluster id in sbom.resource.data line with the cluster id in sbom.cluster.data
          #to show the human readable cluster name in the output
          if [ $CLUSTERID = $WORKLOADCLUSTERID ]; then
            #output the image data and associated package, resource, and cluster data
            dataline=$(echo "$IMAGEDATA,$packagename,$packageversion,$WORKLOADNAME,$WORKLOADTYPE,$WORKLOADNAMESPACE,$CLUSTERNAME")
            dataline="$(echo "$dataline" | sed 's/\t/,/g')"
            echo "$dataline"
          fi
        done < "$i".cluster.data

      done < "$i".resource.data 

    fi
done

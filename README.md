# k8s-find-ingress

Linux shell script to list all ingress rules for a given hostname.

See also blog post: https://www.kaper.com/cloud/find-kubernetes-ingress-rules/

Suppose you have a kubernetes cluster, which contains a large set of ingress rules, of which many are used for the same hostname (just using different context-root's / paths).
In this case it can be hard to find out which rule is used for a certain URL. To help out in this situation I have created a script to make a nice overview of paths
mapped to what services by which ingress rules. You still have to read through the list to find the proper entry for your URL, but it is much quicker than searching through
a bunch of YML files.

The script reports on the cluster which is activated in context. As a little refresher, you can list your available contexts using ```kubectl config get-contexts```
and you can select a context as active by using ```kubectl config use-context SOMENAME```. When you have the proper context activated, just use the script like this:

```
find-ingress.sh some.host.name
```

Or execute the script without parameters to get help, and get a list of available hostnames in your ingress rules.


## Installation:

Note: Only tested on LINUX.

Copy the find-ingress.sh script to a folder which is in your search path, for example to ```/usr/local/bin/``` (or to ```~/bin/```).
Make the script executable, if it was not already: ```chmod 755 /usr/local/bin/find-ingress.sh```.

Make sure you have the following tools installed:

- kubectl  : to query kubernetes (with a working context in ~/.kube/config)
- jq       : to process json (a recent version, older versions do not know about $ENV handling)
- column   : to format data in a table

Note: if you do not like the script suffix of ```.sh```, feel free to rename it to ```find-ingress```. Will work fine also.

For ubuntu/linux-mint, to install jq and column: ```apt-get install bsdmainutils jq```.


## Example data:

If you look in folder example-rules, you see a couple of yml files and two bash scripts.
You can run the ingress-apply.sh script to load the 6 ingress rule examples.
This is assuming that you have a working kubernetes cluster in context ("real" or minikube), with sufficient access rights.

```
$ cd example-rules

$ ./ingress-apply.sh 

ingress.networking.k8s.io/ingress-1 created
ingress.networking.k8s.io/ingress-2 created
ingress.networking.k8s.io/ingress-3 created
ingress.networking.k8s.io/ingress-4 created
namespace/other-ns created
ingress.networking.k8s.io/ingress-5 created
ingress.networking.k8s.io/ingress-6 created
```

The first 4 files are loaded into the default namespace, the last 2 in a new namespace called "other-ns".

When you are done playing around, you can remove the rules by running:

```
$ ./ingress-delete.sh 

ingress.networking.k8s.io "ingress-1" deleted
ingress.networking.k8s.io "ingress-2" deleted
ingress.networking.k8s.io "ingress-3" deleted
ingress.networking.k8s.io "ingress-4" deleted
ingress.networking.k8s.io "ingress-5" deleted
ingress.networking.k8s.io "ingress-6" deleted
namespace "other-ns" deleted
```


## Example 'help' invocation (no parameter):

This example assumes you have loaded the example ingress rules as shown above.

```
$ ./find-ingress.sh 

Usage: ./find-ingress.sh hostname
Example: ./find-ingress.sh www.kaper.com

The following hostnames are available:

test2.kaper.com
test.kaper.com
```

(Note: above example prefixes the script with ```./```, this is only needed if you did not yet put the script in a folder in your search PATH).


## Example invocation (using host parameter):

This example assumes you have loaded the example ingress rules as shown above.

```
$ ./find-ingress.sh test.kaper.com

HOST            PATH                       NAMESPACE  SERVICE       PORT  INGRESS    REWRITE
----            ----                       ---------  -------       ----  -------    -------
test.kaper.com  /                          default    some-nginx-1  8080  ingress-1
test.kaper.com  /echo                      default    echo          80    ingress-4
test.kaper.com  /echo/other                other-ns   echo-4        http  ingress-5
test.kaper.com  /echo/test                 default    echo          80    ingress-4
test.kaper.com  /echo/test/other           other-ns   echo-5        80    ingress-5
test.kaper.com  /idp                       default    idp           9999  ingress-1
test.kaper.com  /route-2(/dummy/|/|$)(.*)  default    some-nginx-2  8080  ingress-2  /$2
test.kaper.com  /route-3                   default    some-nginx-4  8080  ingress-3


$ ./find-ingress.sh test2.kaper.com

HOST             PATH      NAMESPACE  SERVICE        PORT  INGRESS    REWRITE
----             ----      ---------  -------        ----  -------    -------
test2.kaper.com  /         default    some-nginx-10  8000  ingress-3
test2.kaper.com  /route-3  other-ns   some-nginx-4b  8080  ingress-6
test2.kaper.com  /route-4  default    some-nginx-4   8080  ingress-3
```

As you can see in above examples, it is possible that some paths are overlapping. In that case, ingress will use the "best / most-specific" match for each URL to process.


## Conclusion:

A useful little tool (in my humble opinion).

A nice improvement would be to rewrite the tool in for example Go-Lang. This will allow it to be usable on multiple OS-es perhaps.
Another possibility when using Go-Lang might be to add the option to pass in a full URL to the tool, and just show the exact matching
ingress rule as result. This will require implementation of the same algorithm as nginx uses to match path expressions, and pick the
best matching one.

Another future addition (in shell or Go-Lang) could be to show which rules force SSL/HTTPS. In the past, we sometimes had issues if all rules are NOT supposed to
force redirect to HTTPS (e.g. when we have a load balancer in front which handles SSL offload), and then someone by accident deploys a rule which DOES force HTTPS.
That single rule breaks the whole site, and needs to be found quickly ;-)

Thijs Kaper, July 8. 2021.



# ceph_on_vagrant_virtualbox
Installing a Ceph Mimic cluster on vagrant and virtual box environment by running just one command

Steps：
0. Install vagrant and virtual box on your environment
1. vagrant up
2. vagrant ssh ceph-node4
3. ceph -s #you'll see that a three-node ceph cluster is running and ready to use

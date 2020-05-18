package main

import (
	"fmt"
	"io/ioutil"
	rbacv1 "k8s.io/api/rbac/v1"
	"k8s.io/client-go/kubernetes/scheme"
)

func main() {
	filecontent, err := ioutil.ReadFile("/home/kshitij/code/src/gitlab.eng.diamanti.com/software/mcm.git/tenant/tools/cert_02.yaml")
	if err != nil {
		fmt.Printf("%s", err.Error())
		return
	}
	decode := scheme.Codecs.UniversalDeserializer().Decode
	obj, _, _ := decode([]byte(filecontent), nil, nil)

	fmt.Printf("%++v\n\n", obj.GetObjectKind())
	fmt.Printf("%++v\n\n", obj)

	cbl := obj.(*rbacv1.ClusterRoleBindingList) // This fails
	fmt.Printf("%++v\n", cbl)

	switch o := obj.(type) {
	case *rbacv1.ClusterRoleBindingList:
		fmt.Println("correct found") // Never happens
	default:
		fmt.Println("default case")
		_ = o
	}
}

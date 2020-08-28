package main

import (
	"context"
	"flag"
	"fmt"
	"io/ioutil"

	apiextv1beta1 "k8s.io/apiextensions-apiserver/pkg/apis/apiextensions/v1beta1"
	"k8s.io/apimachinery/pkg/api/errors"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/apimachinery/pkg/runtime/serializer"
	clientgoscheme "k8s.io/client-go/kubernetes/scheme"
	"k8s.io/client-go/tools/clientcmd"
	"sigs.k8s.io/controller-runtime/pkg/client"
)

func foo(k *string, files []string) error {

	cfg, err := clientcmd.BuildConfigFromFlags("", *k)
	if err != nil {
		return err
	}
	sch := runtime.NewScheme()
	_ = clientgoscheme.AddToScheme(sch)
	_ = apiextv1beta1.AddToScheme(sch)
	c, err := client.New(cfg, client.Options{Scheme: sch})
	if err != nil {
		return err
	}

	for _, filename := range files {
		filecontent, err := ioutil.ReadFile(filename)
		if err != nil {
			fmt.Printf(err.Error())
			return err
		}

		decode := serializer.NewCodecFactory(sch).UniversalDeserializer().Decode
		obj, gvk, errdecode := decode([]byte(filecontent), nil, nil)

		if errdecode != nil {
			temp := fmt.Sprintf("GVK is :%v, error: %s\n", gvk, errdecode.Error())
			fmt.Printf(temp)
			return errdecode

		}
		if err := c.Create(context.Background(), obj); err != nil {
			if errors.IsAlreadyExists(err) {
				err = c.Update(context.Background(), obj)
				if err != nil {
					temp := fmt.Sprintf("Addon File: %s , error: %s", filename, err.Error())
					fmt.Printf(temp)
				}
			} else {
				temp := fmt.Sprintf("Addon File: %s , error: %s", filename, err.Error())
				fmt.Printf(temp)
			}
		}
	}

	return nil
}

func main() {
	var kubeconfig *string
	kubeconfig = flag.String("kubeconfig", "/home/kshitij/kubeconfig", "absolute path to the kubeconfig file")
	flag.Parse()

	files := []string{"/home/kshitij/code/src/gitlab.eng.diamanti.com/software/mcm.git/tenant/manifests/cert_02.yaml"}
	foo(kubeconfig, files)
}

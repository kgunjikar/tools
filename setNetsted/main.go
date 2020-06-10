/*
Copyright 2019 The Kubernetes Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package main

import (
	"fmt"
	//"github.com/davecgh/go-spew/spew"
	"k8s.io/apimachinery/pkg/apis/meta/v1/unstructured"
	"k8s.io/apimachinery/pkg/runtime"
)

func setNestedFieldNoCopy(obj map[string]interface{}, value interface{}, fields ...string) error {
	m := obj

	for i, field := range fields[:len(fields)-1] {
		if val, ok := m[field]; ok {
			if valMap, ok := val.(map[string]interface{}); ok {
				m = valMap
			} else {
				return fmt.Errorf("value cannot be set because %v is not a map[string]interface{}", fields[:i+1])
			}
		} else {
			newVal := make(map[string]interface{})
			m[field] = newVal
			m = newVal
		}
	}
	m[fields[len(fields)-1]] = value
	return nil
}

func setNestedStringMapSlice(obj map[string]interface{}, value []map[string]interface{}, fields ...string) error {
	m := make([]map[string]interface{}, len(value)) // convert map[string]string into map[string]interface{}
	for k, v := range value {
		m[k] = v
	}
	setNestedFieldNoCopy(obj, m, fields...)
	return nil
}

func setNestedField(obj map[string]interface{}, value interface{}, fields ...string) {

	setNestedFieldNoCopy(obj, runtime.DeepCopyJSONValue(value), fields...)
}

func setUseClusters(u *unstructured.Unstructured, clusters []map[string]interface{}) {

	m := u.Object
	delete(m["spec"].(map[string]interface{}), "useClusters")
	//setNestedFieldNoCopy(u.Object, clusters, "spec")

	dummyMap := m["spec"].(map[string]interface{})
	dummyMap["useClusters"] = clusters
}

func getUseClusters(content map[string]interface{}) []map[string]interface{} {

	spec, uok := content["spec"]
	if uok {
		m, cok := spec.(map[string]interface{})
		if cok {
			useClusters, ok := m["useClusters"]
			if ok {
				return (useClusters.([]map[string]interface{}))
			}
		}
	}
	return nil

}

func main() {
	name := "test"
	tName := "coke"
	cclientName := "coke"
	u := &unstructured.Unstructured{}
	u.Object = map[string]interface{}{
		"spec": map[string]interface{}{
			"tenantName":       tName,
			"projectNamespace": "spektra-" + tName + "-project-" + name,
			"useClusters": []map[string]interface{}{
				{
					"name": cclientName,
				},
			},
			"projectAdmins": []map[string]interface{}{
				{
					"kind":      "ServiceAccount",
					"name":      "spektra-" + tName + "-" + name,
					"namespace": "spektra-" + tName + "-project-" + name,
				},
			},
		},
	}
	useClusters := getUseClusters(u.Object)
	localCluster := []map[string]interface{}{
		{
			"name": cclientName,
		},
	}
	useClusters = append(localCluster, useClusters...)
	setUseClusters(u, useClusters)

	fmt.Printf("%+v", u)
}

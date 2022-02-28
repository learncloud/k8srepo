# CNI install script 가이드
## Prerequisites
* 해당 install script는 폐쇄망 기준 가이드입니다.
* Image repository에 CNI 설치시 필요한 이미지를 push 해야합니다.
    * https://github.com/tmax-cloud/install-cni/tree/5.0 의 폐쇄망 구축 가이드의 1. 과 3. 과정을 진행합니다.

## Step1. cni.config 설정
* 목적: `Calico CNI 설치를 위한 config 변수 설정`
* 순서:
    * 환경에 맞는 config 내용을 작성합니다.
        * registry={IP:PORT}
            * 폐쇄망에서의 image registry 정보를 설정합니다.
            * ex) registry=172.22.8.106:5000
        * cni_version={CNI_VERSION}
            * ex) cni_version=v3.16.6
        * ctl_version={CTL_VERSION}
            * ex) ctl_version=v3.16.6
        * pod_cidr={podSubnet}
            * podSubnet은 kubernetes 설치 시 사용했던 kubeadm-config.yaml의 podSubnet 대역과 동일해야합니다. (다를 경우 문제 발생)
            * 해당 값이 입력되지 않을 경우, CNI 설치가 진행되지 않습니다.
            * ex) pod_cidr=10.0.0.0/16
        * node_cidr={nodeSubnet}
            * nodeSubnet은 node의 NIC이 여러개일 경우, calico-node가 BGP peering을 맺을 node IP 대역입니다.
            * NIC이 하나일 경우, 입력하지 않아도 무방합니다.
            * ex) node_cidr="cidr=192.168.0.0/24"

## Step2. install
* 목적: `Calico 및 calicoctl 설치를 위한 shell script 실행`
* 순서:
  ```bash
   ./install-cni.sh install
  ```
* 비고:
    * cni.config, install-cni.sh 파일과 yaml 디렉토리가 같은 디렉토리 내에 있어야합니다.

## 삭제 가이드
* 목적: `Calico 및 calicoctl 삭제`
* 순서:
  ```bash
   ./install-cni.sh uninstall
  ```
* 비고:
    * cni.config, install-cni.sh 파일과 yaml 디렉토리가 같은 디렉토리 내에 있어야합니다.
    * iptables 룰 및 tunl0 인터페이스 등의 삭제를 위해 스크립트 실행 후 노드 재부팅이 필요합니다.
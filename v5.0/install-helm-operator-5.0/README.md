# Helm Operator 설치 가이드

## 구성 요소 및 버전
* helm-operator (docker.io/fluxcd/helm-operator:1.2.0)

## Prerequisites

## 폐쇄망 구축 가이드
설치를 진행하기 전 아래의 과정을 통해 필요한 이미지 및 yaml 파일을 준비

1. helm 전용 폴더를 만들어줍니다

    ```bash
    mkdir -p ~/helm-operator
    export HELM_OPERATOR_HOME=~/helm-operator
    export HELM_OPERATOR_VERSION=1.2.0

    # image를 push할 폐쇄망 Registry 주소 입력(예:192.168.178.17:5000)
    export REGISTRY=192.168.178.17:5000

    cd $HELM_OPERATOR_HOME
    ```


2. **폐쇄망에서 설치하는 경우** 사용하는 image repository에 helm-operator 설치 시 필요한 이미지를 push
   
    ```bash
    # HelmRelease CRD(Custom Resource Definition, 사용자 지정 리소스) 배포
    curl -LJ -o crds.yaml https://github.com/learncloud/k8srepo/blob/main/v5.0/install-helm-operator-5.0/manifest/crds.yaml?raw=true

    # Helm Operator에 필요한 권한 부여
    curl -LJ -o rbac.yaml https://github.com/learncloud/k8srepo/blob/main/v5.0/install-helm-operator-5.0/manifest/rbac.yaml?raw=true

    # Helm Operator 설치
    curl -LJ -o deployment.yaml https://github.com/learncloud/k8srepo/blob/main/v5.0/install-helm-operator-5.0/manifest/deployment.yaml?raw=true


    ```


* 외부 네트워크 통신이 가능한 환경에서 ingress Controller 구축에 필요한 이미지를 다운받고 생성된 tar파일들을 폐쇄망으로 이동시킨뒤 Registry에 push합니다

    ```
    sudo docker pull docker.io/fluxcd/helm-operator:${HELM_OPERATOR_VERSION}
    sudo docker save docker.io/fluxcd/helm-operator:${HELM_OPERATOR_VERSION} > helm-operator_${HELM_OPERATOR_VERSION}.tar

    sudo docker load < helm-operator_${HELM_OPERATOR_VERSION}.tar

    sudo docker tag docker.io/fluxcd/helm-operator:${HELM_OPERATOR_VERSION} ${REGISTRY}/fluxcd/helm-operator:${HELM_OPERATOR_VERSION}

    sudo docker push ${REGISTRY}/fluxcd/helm-operator:${HELM_OPERATOR_VERSION}

    ```

## 설치 가이드
1. [Namespace 생성](#Step-1-Namespace-생성)
2. [CRD 배포](#Step-2-CRD-배포)
3. [RBAC 설정](#Step-3-RBAC-설정)
4. [Helm Operator 설치](#Step-4-Helm-Operator-설치)

## Step 1. Namespace 생성
* 목적 : `Helm Operator가 설치될 namespace 생성`
* 아래 command로 namespace 생성
	```bash
    kubectl create namespace helm-ns
	```

## Step 2. CRD 배포
* 목적 : `HelmRelease CRD 배포`
* 아래 command로 CRD 배포
	```bash
    kubectl apply -f crds.yaml
	```

## Step 3. RBAC 설정
* 목적 : `Helm Operator에 필요한 권한 부여`
* 아래 command로 RBAC 설정
	```bash
    kubectl apply -f rbac.yaml
	```

## Step 4. Helm Operator 설치
* 목적 : `Helm Operator 설치`
* 아래 command로 deployment 생성
	```bash
    kubectl apply -f deployment.yaml
	```

## 설치 확인
1. [Pod 상태 확인](#Step-1-Pod-상태-확인)
2. [테스트 CR 생성](#Step-2-테스트-CR-생성)

## Step 1. Pod 상태 확인
* 목적 : `Helm Operator 정상 기동 확인`
* 아래 command로 Pod 상태가 running인지 확인
![](https://github.com/learncloud/k8srepo/blob/main/v5.0/install-helm-operator-5.0/figure/helm.png)
    
	

## Step 2. 테스트 CR 생성
* 목적 : `HelmRelease CR를 통한 k8s 리소스 배포 테스트`
  * 샘플 yaml 다운로드
   ```bash
    wget https://raw.githubusercontent.com/tmax-cloud/install-helm-operator/5.0/manifest/podinfo.yaml
    ```
  * 샘플 HelmRelease CR 생성
	```bash
    kubectl apply -f podinfo.yaml
	```
  * k8s 리소스 정상 배포 확인
    ```console
	  $ kubectl get pods -n helm-ns
      NAME                               READY   STATUS    RESTARTS   AGE
      helm-ns-podinfo-575694ddd4-rz2qq   1/1     Running   0          19s
    ```
  * 샘플 리소스 제거
	```bash
    kubectl delete -f podinfo.yaml
	```

## 삭제 가이드
1. [Helm Operator 리소스 제거](#Step-1-Helm-Operator-리소스-제거)

## Step 1. Helm Operator 리소스 제거
* 목적 : `Helm Operator 관련 리소스 제거`
* 아래 command로 리소스 제거
	```bash
    kubectl delete -f deployment.yaml
    kubectl delete -f rbac.yaml
    kubectl delete -f crds.yaml
    kubectl delete namespace helm-ns
	```

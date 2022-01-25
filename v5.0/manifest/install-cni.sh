#!/bin/bash

install_dir=$(dirname "$0")
. ${install_dir}/cni.config
yaml_dir="${install_dir}/yaml"

function init() {
    echo "---Initialize CNI environment---"
    if [[ -z ${registry} ]]; then
        registry=""
    else
        registry=${registry}
    fi

    if [[ -z ${cni_version} ]]; then
        cni_version=v3.16.6
    else
        cni_version=${cni_version}
    fi

    if [[ -z ${ctl_version} ]]; then
        ctl_version=v3.16.6
    else
        ctl_version=${ctl_version}
    fi

    if [[ -z ${pod_cidr} ]]; then
        echo "pod_cidr is empty, exit"
        exit 100
    else
        pod_cidr=${pod_cidr}
    fi

    if [[ -z ${node_cidr} ]]; then
        node_cidr=first-found
    else
        node_cidr=cidr\=${node_cidr}
    fi


    # Change calico image version
    sed -i 's|v3.16.6|'${cni_version}'|g' ${yaml_dir}/calico.yaml

    # Change calicoctl image version
    sed -i 's|v3.16.6|'${ctl_version}'|g' ${yaml_dir}/calicoctl.yaml

    # Disable IP in IP Mode
    sed -i '/CALICO_IPV4POOL_IPIP/{n;s|^\([[:space:]]\+value:\).*|\1 "Never"|}' ${yaml_dir}/calico.yaml

    # Set Pod CIDR
    sed -i '/CALICO_IPV4POOL_CIDR/{n;s|^\([[:space:]]\+value:\).*|\1 '\"${pod_cidr}\"'|}' ${yaml_dir}/calico.yaml

    # Set IP_AUTODETECTION_METHOD
    sed -i '/IP_AUTODETECTION_METHOD/{n;s|^\([[:space:]]\+value:\).*|\1 '\"${node_cidr}\"'|}' ${yaml_dir}/calico.yaml

    # Set registry address when exists
    if [[ ! -z ${registry} ]]; then
        sed -i 's/calico\/cni/'${registry}'\/calico\/cni/g' ${yaml_dir}/calico.yaml
        sed -i 's/calico\/pod2daemon-flexvol/'${registry}'\/calico\/pod2daemon-flexvol/g' ${yaml_dir}/calico.yaml
        sed -i 's/calico\/node/'${registry}'\/calico\/node/g' ${yaml_dir}/calico.yaml
        sed -i 's/calico\/kube-controllers/'${registry}'\/calico\/kube-controllers/g' ${yaml_dir}/calico.yaml
        sed -i 's/calico\/ctl/'${registry}'\/calico\/ctl/g' ${yaml_dir}/calicoctl.yaml
    fi

    echo "---CNI initialization complete---"
}

function install() {
    echo "---Installing CNI---"

    kubectl apply -f ${yaml_dir}/calico.yaml
    kubectl apply -f ${yaml_dir}/calicoctl.yaml

    echo "---CNI installation complete---"
}

function uninstall() {
    echo "---Uninstalling CNI---"

    kubectl delete -f ${yaml_dir}/calico.yaml
    kubectl delete -f ${yaml_dir}/calicoctl.yaml

    echo "---CNI uninstallation complete---"
}

function main() {
    case "${1:-}" in
    install)
        init
        install
        ;;
    uninstall)
        uninstall
        ;;
    *)
        set +x
        echo "service list:" >&2
        echo "  $0 install" >&2
        echo "  $0 uninstall" >&2
        ;;
    esac
}

main $1
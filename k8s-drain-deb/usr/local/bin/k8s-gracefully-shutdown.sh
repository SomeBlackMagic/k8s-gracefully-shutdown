#!/bin/bash

# Получаем имя узла
NODE_NAME=$(hostname)

# Функция для подсчета контейнеров
count_containers() {
    crictl ps -q | wc -l
}

# Функция для отображения анимации и количества контейнеров
show_animation() {
    while true; do
        CONTAINER_COUNT=$(count_containers)
        whiptail --title "Kubernetes Node Drain" --infobox "Draining node... \n\nRunning containers: $CONTAINER_COUNT" 8 40
        sleep 1
    done
}

# Запускаем анимацию в фоновом процессе
show_animation &
ANIMATION_PID=$!

export KUBECONFIG=/etc/kubernetes/kubelet.conf
# Делаем drain узла
kubectl drain "$NODE_NAME" --ignore-daemonsets --delete-emptydir-data --force

# Проверяем статус команды drain
if [ $? -ne 0 ]; then
    echo "Drain failed"
    kill $ANIMATION_PID
    exit 1
fi

# Останавливаем анимацию
kill $ANIMATION_PID

echo "Node drained successfully"
exit 0

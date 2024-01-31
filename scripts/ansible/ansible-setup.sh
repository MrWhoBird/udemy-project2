#!/bin/bash
sudo -i
apt update -y
apt install software-properties-common -y
add-apt-repository --yes --update ppa:ansible/ansible
apt install ansible -y

cat <<EOT>> ./etc/ansible/jenkins-master-setup.yml
---
- hosts: jenkins-master
  become: true
  tasks:
  - name: add jenkins key
    apt_key:
      url: https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
      state: present

  - name: add jenkins repo
    apt_repository:
      repo: 'deb https://pkg.jenkins.io/debian-stable binary/'
      state: present

  - name: install java
    apt:
      name: openjdk-11-jre
      state: present

  - name: install jenkins
    apt:
      name: jenkins
      state: present

  - name: start jenkins service
    service:
      name: jenkins
      state: started

  - name: enable jenkins service
    service:
      name: jenkins
      enabled: yes
EOT

cat <<EOT>> ./etc/ansible/jenkins-slave-setup.yml
---
- hosts: jenkins-slave
  become: true
  tasks:
    - name: update ubuntu repo and cache
      apt:
        update_cache: yes
        cache_valid_time: 3600

    - name: install java
      apt:
        name: openjdk-11-jre
        state: present
    
    - name: download maven
      get_url:
        url: https://dlcdn.apache.org/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz
        dest: /opt

    - name: extract maven
      unarchive:
        src: /opt/apache-maven-3.9.6-bin.tar.gz
        dest: /opt
        remote_src: yes

    - name: install docker
      apt:
        name: docker.io
        state: present
    
    - name: start docker services
      service:
        name: docker
        state: started
    
    - name: enable docker service
      service:
        name: docker
        enabled: yes
EOT
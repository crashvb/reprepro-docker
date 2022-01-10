pipeline {
	agent {
		label "docker"
	}
	environment {
		DOCKER_IMAGE_NAME = "crashvb/reprepro"
		DOCKER_TAG = "latest"
		instance = ""
		tag_commit = sh(
			script: "git rev-parse --short=12 --verify HEAD",
			returnStdout: true
		).trim()
		tag_date = sh(
			script: "date '+%Y%m%d%H%M'",
			returnStdout: true
		).trim()
	}
	stages {
		stage("build") {
			steps {
				script {
					dockerfile = ("${env.DOCKER_TAG}" != "latest") ? "${env.DOCKER_TAG}/" : "."
					instance = docker.build(
						"${env.DOCKER_IMAGE_NAME}:${env.BUILD_ID}",
						"--build-arg=org_opencontainers_image_created=${env.tag_date} \
						--build-arg=org_opencontainers_image_revision=${env.tag_commit} \
						--force-rm=true \
						--no-cache=true \
						--pull=true \
						${dockerfile}"
					)
				}
			}
		}
		stage("deploy") {
			steps {
				script {
					docker.withRegistry("https://index.docker.io/v1/", "dockerhub-token") {
						tag_prefix = ("${env.DOCKER_TAG}" != "latest") ? "${env.DOCKER_TAG}-" : ""
						instance.push("${tag_prefix}${tag_commit}")
						instance.push("${tag_prefix}${tag_date}")
						instance.push("${env.DOCKER_TAG}")
					}
				}
			}
		}
	}
}

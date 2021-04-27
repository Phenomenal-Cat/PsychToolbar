pipeline {
    agent any
    triggers {
        cron('H * * * *')
    }
    stages {
        stage ('Create virtualenv') {
            steps {
                echo 'Create virtualenv..'
                sh '/library/software/python/Python-3.8.6-install/bin/python3 -m venv .'
            }
        }
        stage ('Install Sphinx') {
            steps {
                echo 'Install Sphinx..'
                sh 'source bin/activate && export LD_LIBRARY_PATH=/library/software/openssl/openssl-1.1.1h-install/lib/; pip3 install -r requirements.txt'
            }
        }
        stage ('Create HTML') {
            steps {
                echo 'Run Sphinx..'
                sh 'source bin/activate && make sphinx-build'
            }
        }
        stage ('Deploy HTML') {
            steps {
                echo 'Deploy..'
                sh 'rsync -av --partial --progress source/_build/html/ /srv/website/doc/nif-internal'

            }
        }
    }
}

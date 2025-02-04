pipeline {
    agent any
    triggers {
        cron('0 0 * * *')
    }
    stages {
        stage ('Create virtualenv') {
            steps {
                echo 'Create virtualenv..'
                sh 'python3.9 -m venv .'
            }
        }
        stage ('Install Sphinx') {
            steps {
                echo 'Install Sphinx..'
                 sh 'source bin/activate && pip3 install -r PTB_Docs/requirements.txt'
            }
        }
        stage ('Create HTML') {
            steps {
                echo 'Run Sphinx..'
                sh 'source bin/activate && cd PTB_Docs; make sphinx-build'
            }
        }
        stage ('Deploy HTML') {
            steps {
                echo 'Deploy..'
                sh 'cd PTB_Docs; make deploy'
            }
        }
    }
}

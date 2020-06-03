#!/bin/bash

#
# Public Variables ...
PACK=./pack
VERSION=0.0.1
RESOURCE=../../resources
CORE=$PACK/x-framework-core-$VERSION.tgz
SERVICES=$PACK/x-framework-services-$VERSION.tgz
COMPONENTS=$PACK/x-framework-components-$VERSION.tgz

#
# Failed App ...
function failed() {
  echo " "
  if [ ! -z "$1" ]; then
    echo "$1"
  fi
  echo "Exit With Error ..."
  read anyKeyToExit
  exit 1
}

function createProject() {
  echo "Creating Angular Project ..."
  cd projects
  ng new $projectName
  cd ..
  prepareProject
}

function prepareProject() {
  #
  # Check Project Exists or not ...
  if [ ! -d "projects/$projectName" ]; then
    failed "Project doesn't exists ..."
  fi

  cd projects

  #
  # adding Packages.json ...
  PACKAGES=$projectName/package.json
  if [ ! -f "$PACKAGES" ]; then
    echo $PACKAGES
    failed "package.json file doesn't exists ..."
  fi

  cd $projectName

  echo " "
  echo "add Angular Material ..."
  read -r -p "press any key to coninue ..." anykey
  ng add @angular/material

  echo " "
  echo "Installing DevDependencies ..."
  read -r -p "press any key to coninue ..." anykey
  npm install --save-dev @angular/cli @types/crypto-js@3.1.43 @types/howler@2.1.2 @ionic/angular-toolkit@2.2.0

  echo " "
  echo "Installing Dependencies ..."
  read -r -p "press any key to coninue ..." anykey
  npm install -s @angular/router @angular/material-moment-adapter @angular/flex-layout @ionic/angular hammerjs angular-gridster2@9.1.0 crypto-js@4.0.0 howler@2.1.3 jalali-moment@3.3.3 libphonenumber-js@1.7.48 md5-typescript@1.0.5 moment@2.24.0 ngx-device-detector@1.4.1 ngx-md@8.1.6 ol@6.2.1 ol-ext@3.1.10

  echo " "
  echo "Installing XFramework Modules ..."
  read -r -p "press any key to coninue ..." anykey
  CORE_ADDR=../../$CORE
  SERVICES_ADDR=../../$SERVICES
  COMPONENTS_ADDR=../../$COMPONENTS
  npm install $CORE_ADDR $SERVICES_ADDR $COMPONENTS_ADDR

  echo " "
  echo "Integrating Assets ..."
  read -r -p "press any key to coninue ..." anykey
  cp -R ./node_modules/x-framework-components/assets/. ./src/assets/ || true

  echo " "
  echo "Integrating npm scripts ..."
  read -r -p "press any key to coninue ..." anykey
  prepareDependencies="fx package.json '{...this, scripts: {...this.scripts,  \"prepareDependencies\": \"npm i -s $CORE_ADDR $SERVICES_ADDR $COMPONENTS_ADDR\"}}' save .scripts"
  eval $prepareDependencies
  serveXFrameworkProject="fx package.json '{...this, scripts: {...this.scripts,  \"serveXFrameworkProject\": \"npm run prepareDependencies && ng serve -o\"}}' save .scripts"
  eval $serveXFrameworkProject

  echo " "
  echo "Configure XFramework ..."
  read -r -p "press any key to coninue ..." anykey
  if [ ! -d "./src/app/config" ]; then
    mkdir ./src/app/config
  fi
  cp -R $RESOURCE/config/. ./src/app/config/
  cp -R $RESOURCE/environments/. ./src/environments
  if [ -f "./src/favicon.ico" ]; then
    rm ./src/favicon.ico || true
  fi
  cp -R $RESOURCE/favicon.png ./src/assets/icon/
  mkdir ./src/assets/image
  cp -R $RESOURCE/favicon.png ./src/assets/image/logo.png
  cp -R $RESOURCE/index.html ./src/
  cp -R $RESOURCE/main.ts ./src/
  if [ -f "./src/styles.scss" ]; then
    rm ./src/styles.scss || true
  fi
  if [ -f "./src/styles.css" ]; then
    rm ./src/styles.css || true
  fi
  if [ -f "./src/app/app.component.css" ]; then
    rm ./src/app/app.component.css || true
  fi
  if [ -f "./src/app/app.component.spec.ts" ]; then
    rm ./src/app/app.component.spec.ts || true
  fi
  cp -R $RESOURCE/app.module.ts ./src/app
  cp -R $RESOURCE/app.component.ts ./src/app
  cp -R $RESOURCE/app.component.scss ./src/app
  cp -R $RESOURCE/app.component.html ./src/app
  cp -R $RESOURCE/app-routing.module.ts ./src/app
  cp -R $RESOURCE/views/. ./src/app/views/
  cp -R $RESOURCE/pages/. ./src/app/pages/
  cp -R $RESOURCE/.editorconfig ./
  cp -R $RESOURCE/theme/. ./src/theme

  #
  # Fix angular.json File ...
  cp -R $RESOURCE/angular.json ./
  sed -i.bkp "s/\$APP_NAME/$projectName/g" ./angular.json
  rm ./angular.json.bkp

  #
  # prepare README.md ...
  cp -R $RESOURCE/README.md ./
  sed -i.bkp "s/\$APP_NAME/$projectName/g" ./README.md
  rm ./README.md.bkp

  #
  # Setting Startup Language ...
  echo " "
  echo "by default XFramework add support for en-US and fa-IR localizations"
  echo "you can add more localization supports later ..."
  echo " "
  read -r -p "Select default localization [en/fa(default)]: " locale
  case $locale in
  en | En | eN | EN)
    sed -i.bkp "s/export const DefaultLocale: XLocale = 'fa-IR';/export const DefaultLocale: XLocale = 'en-US';/g" ./src/app/config/localization.config.ts
    rm ./src/app/config/localization.config.ts.bkp
    ;;
  esac

  #
  # add Cordova Typing ...
  mkdir ./typings
  cp -R $RESOURCE/typings/* ./typings

  #
  # Add Ionic Support ...
  echo " "
  read -r -p "do you like to add ionic cli support to $projectName [y/n] ? " addIonicSupport
  if [[ "$addIonicSupport" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    #
    echo " "
    echo "Add Ionic Support ..."
    echo " "
    pNameForId=$(tr A-Z a-z <<<$projectName)
    defIonicAppId="ir.saherelm.x-framewor.$pNameForId"
    read -r -p "enter ionic appId (Reverse domain-style identifier) [$defIonicAppId] ? " ionicAppId
    if [ -z "$ionicAppId" ]; then
      ionicAppId=$(tr A-Z a-z <<<$defIonicAppId)
    else
      ionicAppId=$(tr A-Z a-z <<<$ionicAppId)
    fi
    if [ ! -z "$ionicAppId" ]; then
      echo " "
      echo "preparing ionic app [$ionicAppId] ..."
      #
      # Preparing ionic config file ...
      cp -R $RESOURCE/ionic.config.json ./
      sed -i.bkp "s/\$APP_NAME/$projectName/g" ./ionic.config.json
      rm ./ionic.config.json.bkp

      #
      # Preparing capacitor config file ...
      cp -R $RESOURCE/capacitor.config.json ./
      sed -i.bkp -e "s/\$APP_NAME/$projectName/g" -e "s/\$APP_ID/$ionicAppId/g" ./capacitor.config.json
      rm ./capacitor.config.json.bkp

      #
      # Installing Dependencies ...
      echo " "
      echo "Installing Dependencies ..."
      npm install -s @ionic-native/core @ionic-native/splash-screen @ionic-native/status-bar
    fi
  fi

  #
  # Add Pwa Support ...
  echo " "
  read -r -p "do you like to add PWA support to $projectName [y/n] ? " addPwaSupport
  if [[ "$addPwaSupport" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    #
    echo " "
    echo "Add PWA Support ..."
    ng add @angular/pwa
  fi

  cd ..

  echo " "
  echo "Next Steps :"
  echo " - Checkout TODO expressions and apply changes;"
  echo " - implement Business Logic;"
  echo " "
  echo "pross any key to exist ..."
  read anykey

  exit 0
}

function startup() {
  #
  # Check Pack Folder ...
  if [ ! -d "resources" ]; then
    failed "Resources Folder doesn't exists ..."
  fi
  if [ ! -d "$PACK" ]; then
    failed "Pack Folder doesn't exists ..."
  fi
  if [ ! -f "$CORE" ]; then
    failed "xFramework Core Module doesn't exists ..."
  fi
  if [ ! -f "$SERVICES" ]; then
    failed "xFramework Services Module doesn't exists ..."
  fi
  if [ ! -f "$COMPONENTS" ]; then
    failed "xFramework Components Module doesn't exists ..."
  fi

  #
  # Checking Required Commands ...
  type ng >/dev/null 2>&1 || failed "ng required but not installed ..."
  type npm >/dev/null 2>&1 || failed "npm required but not installed ..."
  type sed >/dev/null 2>&1 || failed "sed required but not installed ..."
  type git >/dev/null 2>&1 || failed "git required but not installed ..."
  type fx >/dev/null 2>&1 || failed "fx required but not installed, installing it: $ npm install -g fx"

  #
  if [ ! -d "./projects" ]; then
    mkdir projects
  fi

  #
  # Updating Pack ...
  echo " "
  echo "Please wait until update proccess finished ..."
  git submodule foreach 'git pull origin master' || failed "can't update resources, check internet connection and try again ..."
  clear

  #
  # Intruduction ...
  echo " "
  echo "XFramework Project Maker ver $VERSION"
  echo " "
  echo "this is a tool to create an XFramework Based Angular Project ..."
  echo "hope to enjoy it ..."
  echo " "
  echo "Hadi Khazaee Asl"
  echo "https://www.saherelm.ir"
  echo "hadi_khazaee_asl@yahoo.com"
  echo " "

  #
  # Get Project Name ...
  echo -n "new XFramework based Project Name [$1] ? "
  read projectName
  if [ ! -z "$1" ]; then
    projectName=$1
  fi
  if [ -z "$projectName" ]; then
    failed "Invalid Project Name ..."
  fi
  if [ -d "projects/$projectName" ]; then
    echo " "
    echo "Project Directory already Exists ..."
    read -r -p "prepare it [y/n] ?" prepareCurrentProject
    if [[ "$prepareCurrentProject" =~ ^([yY][eE][sS]|[yY])$ ]]; then
      prepareProject
    else
      failed "Duplicate Project Name ..."
    fi
  fi

  #
  # Create Project ...
  createProject
}

startup $*

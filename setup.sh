function requirements () {
	if ! command -v flutter &> /dev/null
	then
		echo "flutter could not be found"
		exit
	fi
}

function setup () {
	echo -e "\n\e[1;46mSetting up\e[0m";
	rm -rf .env && cp .env.example .env
	echo "Installing dependencies...";
	rm -rf .dart_tool > /dev/null;
	flutter pub get > /dev/null;
	echo "Dependencies installed";
  echo "Go to https://trello.com/app-key to get your API key and app name."
    read -p "Enter the API key: " api_key
    read -p "Enter the app name: " app_name
    if [[ "$(uname)" == "Linux" ]]; then
        sed -i "s/TRELLO_API_TOKEN=.*/TRELLO_API_TOKEN=${api_key}/g" .env
        sed -i "s/TRELLO_APP_NAME=.*/TRELLO_APP_NAME=${app_name}/g" .env
    elif [[ "$(uname)" == "Darwin" ]]; then
        sed -i '' "s/TRELLO_API_TOKEN=.*/TRELLO_API_TOKEN=${api_key}/g" .env
        sed -i '' "s/TRELLO_APP_NAME=.*/TRELLO_APP_NAME=${app_name}/g" .env
    fi
	echo -e "\nThe API key is ${api_key}";
  echo -e "\nThe app name is ${app_name}";
  echo -e "\n\e[1;46mSetup complete\e[0m";
}

requirements;
setup;

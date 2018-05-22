# docker-ruby-chrome-headless
It is a dockerfile for running tests with capybara/selenium with chrome/chromedriver.

---

### Setup
**Dependency:** *[docker](https://docs.docker.com/install/)*

```git pull git@github.com:josuehenrique/docker-ruby-chrome-headless.git```

```cd docker-ruby-chrome-headless && docker build -t josuehenrique/rubychromeheadless:latest .```

```docker run --name=rubychromeheadless -it josuehenrique/rubychromeheadless:latest --build-arg ssh_prv_key="$(cat ~/.ssh/id_rsa)" --build-arg ruby_version="YOUR.RUBY.VERSION" --build-arg project_ssh_url="YOUR_SSH_PROJECT_URL" --build-arg project_name="YOUR_PROJECT_NAME" bash ```

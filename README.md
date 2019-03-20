# Codeship Excess Build Killer

This repo has a webhook server suitable for receiving the "push" event
from github. When such an event is received it will check the configured
codeship account for any builds that are either running or waiting on
the same branch and stop them automatically for you.

[![Deploy on Heroku](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

# In bash
# -------
#
# On Fedora, may need to use `podman` instead of `docker`.
#
# docker pull selenium/standalone-chrome
# docker run -it --rm -p 4444:4444 selenium/standalone-chrome:latest
#
# In a new terminal:
# curl -sSL "http://localhost:4444/wd/hub/status"
#
# ctrl-c to stop it
# docker ps --all
# docker stop <NAME>  # like elegant_bardeen, probably can use `--all`
# docker rm <NAME>    # probably can use `--all`
# docker ps --all


# Now in python
from selenium import webdriver 
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities 


driver = webdriver.Remote( 
    command_executor='http://127.0.0.1:4444/wd/hub', 
    desired_capabilities=DesiredCapabilities.CHROME)


driver.get("http://www.google.com")

# and whatever else you do with the regular WebDriver

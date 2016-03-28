#### **Shiny Password:** 
##### **A simple (and not particularly secure) method for managing user access permissions in Shiny apps**


RStudio's product Shiny allows users to easily build interactive web applications backed by an R session. Shiny applications can be served to end users via three mechanisms:

- [shinyapps.io](http://www.shinyapps.io/) (RStudio's hosting platform)
- [Shiny server open-source](https://www.rstudio.com/products/shiny/download-server/) (free and open source)
- [Shiny Server Pro](https://www.rstudio.com/products/shiny-server-pro/)


Both Shiny Server Pro and the highest two tiers of shinyapps.io allow administrators to set app-specific user access permissions. However, some users of shinyapps.io's lower tiers or Shiny server open-source may want to control app access as well.


The most secure method for accomplishing this with Shiny server open-source is to [host the app behind a reverse proxy server](https://support.rstudio.com/hc/en-us/articles/213733868-Running-Shiny-Server-with-a-Proxy) that will manage web traffic to and from the Shiny server. The reverse proxy server can then use standard user access control tools such as [Auth0](https://auth0.com/blog/2015/09/24/adding-authentication-to-shiny-open-source-edition/) or [PAM](https://en.wikipedia.org/wiki/Pluggable_authentication_module).


However, in some deployment environments using a reverse proxy may not be possible - this Shiny app template is designed for those scenarios. This app code conducts user authentication inside the Shiny app itself.


This approach does not resolve Shiny server open-source's use of an unencrypted web connection (it uses HTTP instead of HTTP**_S_**). A user password will be passed to the Shiny server in clear text, so anyone snooping on the web connection will be able to steal it.


***
##### **WARNING AND DISCLAIMER:**
**I am not a security professional. This app template provides an *extremely* mild form of access control that can be easily circumvented by a knowledgable adversary.**

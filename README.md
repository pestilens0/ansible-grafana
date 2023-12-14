Made by Edvin.

This project is dedicated to installing Grafana application with Ansible, alongside with Prometheus and Node exporter. <br />
The project has been prepared and deployed on CentOS 7 Minimal with fully updated packages.

Usage:  <br />
```
ansible-playbook playbooks/stack.yml ### Full instalation
ansible-playbook playbooks/grafana.yml ### Grafana + Nginx reverse proxy only (tags: ntp, firewall, grafana, nginx, users)
ansible-playbook playbooks/prometheus.yml ### Prometheus only (tags: prometheus, datasource)
ansible-playbook playbooks/node_exporter.yml ### Node Exporter only
```
Before executing the playbooks, make sure the hosts file corresponds to your current network configuration. Also make sure that your RSA key has been distributed to target VMs as an authorized_key and you can ssh from Ansible host to target nodes. <br />
Also community.grafana Ansible module is needed for user and datasouce creation, it can be installed like so:
```
ansible-galaxy collection install community.grafana
```
# Grafana role

Since Grafana was the main goal of the task, it consists of multiple stages, some not necessarily related to Grafana application. <br /> <br />
Firstly the firewall is being configured. The way I did it, was using a collection of scripts contained in roles/grafana/files/etc/firewall.d, as well as the main script that applies those rules, contained in roles/grafana/files/etc/firewall.sh. <br />
The advantage of handling the firewall like this greatly simplifies the addition or removal of rules, since they are basically files located in roles/grafana/files/etc/firewall.d. Since the scipts are in Jinja2, files can also be used with ansible group and host variables. In order to change firewall rules, we only have to add or remove existing onces from roles/grafana/files/etc/firewall.d and run the playbook like so:
```
ansible-playbook playbooks/grafana.yml --tags=firewall
```
Also, it's very helpful in testing on the server itself, since in order to test a new firewall rule we simply have to create a new file inside /etc/firewall.d and execute the main firewall script: /etc/firewall.sh. After the execution, all of the temporary rules that aren't located in /etc/firewall.d will be terminated and only the relevant ones will remain. <br />
In my example, only subnet  192.168.8.0/24 is allowed on ports 8080 (Grafana UI) and 22 (Ansible SSH).<br /><br />

Next the Grafana is being installed, along with Nginx reverse proxy. Nginx is a good addition in this case, as reverse proxy does improve security as well as performance, since it does prevent direct exposure, allow caching, load balancing and overall makes webservers easier to manage.<br />
Reverse proxy has been setup with some tips from the official guide: https://grafana.com/tutorials/run-grafana-behind-a-proxy/<br />

One thing that I should note, Nginx task set does include a task for adding SElinux exception for httpd_t, as Grafana has been installed on a server with SElinux fully enabled. This is indeed a security compromise, however only other way around it would be to fish out the rule using audit2allow during the playbook execution to make the exception more concise. This indeed can be done, but it would require more time and additional troubleshooting, which (at the moment of writing) I did not have. <br /> <br />

Lastly, Grafana users are being created with the help of community.grafana module. It's pretty self-explanatory, a new user "grafana" is being created using password as a variable from Ansible vault, default "admin" user is being deleted.<br /><br />

# Prometheus role
I have decided to add Prometheus, as Grafana by itself would't be that interesting to use, since it doesn't have any data source. <br /><br />
Installation of Prometheus is pretty straightforward, binaries are being downloaded, untarred and converted into services, with configuration being stored in /etc/prometheus. I have decided to use a hardcoded version due to reliability and the fact that it runs fine with this particular setup, however adding a version as a variable would also be an option.<br />
One noteworthy thing about the task set, is (again) with the help of community.grafana module, a default Prometheus data source is being added straight to Grafana.<br />

Prometheus has been setup with some tips from the official guide: https://grafana.com/docs/grafana/latest/getting-started/get-started-grafana-prometheus/

# Node Exporter role
Node Exporter has been added to populate Prometheus with some actual data that can be displayed. The setup is almost identical to Prometheus, it's also using a hardcoded version.<br />
Again, Node Exporter has been setup with some tips from the official guide: https://grafana.com/docs/grafana-cloud/send-data/metrics/metrics-prometheus/prometheus-config-examples/noagent_linuxnode/#configure-a-dashboard<br /><br />

Once the playbook has been successfully executed, user can access the webserver via http://192.168.8.*:8080 (depending on your network setup), login using the credentials grafana:grafana123 and immediately use "Explore" to display data transferred by Node Exporter (metrics with "node" prefix).

## Disclaimers
Project should not be treated as "production ready", there are many areas of improvement, such as:<br />
*Adding TLS/SSL <br />
*Enhancing the security by adding API token athentication to Grafana API<br />
*Adding authentication to Prometheus DB<br />
*Using a more serious database as backed for Grafana, such as Percona<br />
*Adding ansible inventory variables for versions and firewall rules<br />
To only note a few.

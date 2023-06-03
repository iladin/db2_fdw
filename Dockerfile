FROM ibmcom/db2
ENV LICENSE accept
ENV DB2INST1_PASSWORD passw0rd
ENV DBNAME dbname 

# Install the repository RPM:
RUN dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm \
# Disable the built-in PostgreSQL module:
&& dnf -qy module disable postgresql \
&& dnf install epel-release -y\
&& dnf install -y gcc-toolset-11-gcc curl patch make perl git python2 m4 cpp kernel-devel kernel-headers gcc-c++ \
&& useradd -m -s /bin/bash linuxbrew && echo 'linuxbrew ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers

# Install linuxbrew:

USER linuxbrew
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:/home/linuxbrew/.linuxbrew/opt/postgresql@15/bin:$PATH"
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)" \
&& brew install curl postgresql@15 binutils gcc@11 && brew link binutils --force

# setup for db2 as well as paths for compiles
RUN export DB2_HOME=/opt/ibm/db2/V11.5 \
&& echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bash_profile \
&& echo "export DB2_HOME=$DB2_HOME" >> ~/.bash_profile \
&& echo 'export PATH=$DB2_HOME/bin:$PATH' >> ~/.bash_profile \
&& echo 'source $DB2_HOME/cfg/db2profile' >> ~/.bash_profile \
&& echo "export LDFLAGS=-L/home/linuxbrew/.linuxbrew/opt/postgresql@15/lib -L$DB2_HOME/lib{64,32}" >> ~/.bash_profile \
&& echo 'export CPPFLAGS="-I/home/linuxbrew/.linuxbrew/opt/postgresql@15/include -I$DB2_HOME/include"' >> ~/.bash_profile

# This the Entrypoint from ibmcom/db2; Generate as a , script
RUN echo /var/db2_setup/lib/setup_db2_instance.sh > $HOME/, && chmod a+x $HOME/,

WORKDIR /workspace
RUN chmod -R a+w /workspace

FROM odoo:10.0
MAINTAINER cxinde <cxinde@outlook.com>

USER root
# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
RUN	apt-get update
RUN apt-get install -y --no-install-recommends build-essential libsasl2-dev libldap2-dev libssl-dev libffi-dev python-dev \
    && pip install -U pip \
	&& pip install --upgrade pip setuptools \
	&& pip install cryptography \
	&& pip install wechatpy \
	&& pip install redis \
	&& pip install rabbitmq \
	&& pip install celery \
	&& pip install pika \
	&& pip install dicttoxml

RUN apt-get install unzip 
# 安装FDFS客户端驱动
RUN curl -o fdfs.zip -SL https://gitee.com/tyibs/fdfs_client/repository/archive/master.zip \
        && unzip -q fdfs.zip 
WORKDIR fdfs_client
RUN python setup.py install
# 回来原目录
WORKDIR /
RUN rm -rf fdfs_client \
    && rm -rf fdfs.zip

# 替换掉原有的odoo 模块
RUN curl -o odoo.zip -SL https://github.com/cxinde/odoo10_lightly/archive/windows.zip \
        && unzip -q odoo.zip \
        && rm -rf odoo.zip 
RUN cp /usr/lib/python2.7/dist-packages/odoo/addons/__init__.py odoo10_lightly-windows/addons/
RUN rm -rf /usr/lib/python2.7/dist-packages/odoo/addons \
        && mv odoo10_lightly-windows/addons /usr/lib/python2.7/dist-packages/odoo/ \
        && mv odoo10_lightly-windows/odoo/addons/* /usr/lib/python2.7/dist-packages/odoo/addons \
        && rm -rf odoo10_lightly-windows/ 
#RUN ls -al /usr/lib/python2.7/dist-packages/odoo/addons 
# 添加中文字体
# RUN apt-get install -y --no-install-recommends ttf-wqy-microhei ttf-wqy-zenhei
ADD zh_CN/ /usr/share/fonts
RUN fc-cache /usr/share/fonts/zh_CN

# create fdfs client config folder
RUN mkdir -p /etc/fdfs/
COPY ./client.conf /etc/fdfs/
RUN rm -rf odoo_10_dev_lightly

# set fdfs client config permision
RUN chown odoo:odoo /etc/fdfs/client.conf \
	&& chmod -R 0640 /etc/fdfs/client.conf
RUN chown -R odoo:odoo /usr/lib/python2.7/dist-packages/odoo/addons
RUN chown -R odoo:odoo /var/lib/odoo
USER odoo

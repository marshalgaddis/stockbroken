from django.conf.urls import patterns, url

from stocks import views

urlpatterns = patterns('',
    url(r'^$', views.index, name='index'),
    url(r'^(?P<stock_id>\d+)/$', views.detail, name='detail'),
    url(r'^(?P<stock_id>\d+)/plot/$', views.plot, name='plot'),
    url(r'^retrieve/$', views.retrieve, name='retrieve'),
)


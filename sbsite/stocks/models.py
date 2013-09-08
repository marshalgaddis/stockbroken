from django.db import models
import datetime
from django.utils import timezone

# Create your models here.


class Stock(models.Model):
    ticker = models.CharField(max_length=5)
    start_date = models.DateTimeField('date shorted')

    def __unicode__(self):
        return self.ticker


class Tick(models.Model):
    stock = models.ForeignKey(Stock)
    time = models.DateTimeField('time')
    price = models.FloatField('price')

    def __unicode__(self):
        time_repr = self.time.strftime('%Y-%m-%d %H:%M:%S')
        tick_repr = time_repr + ": " + str(self.price)
        return tick_repr

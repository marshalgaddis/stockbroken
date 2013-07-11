# Create your views here.
from django.shortcuts import get_object_or_404, render
from django.http import HttpResponseRedirect, HttpResponse
from django.core.urlresolvers import reverse

from stocks.models import Stock, Tick
from quotehandlers.googlequotes import *

import datetime
from django.utils import timezone
from django.utils.dateparse import parse_datetime

from rpy2 import robjects
from rpy2.robjects import Formula
from rpy2.robjects.vectors import IntVector, FloatVector
from rpy2.robjects.lib import grid
from rpy2.robjects.packages import importr

# The R 'print' function
rprint = robjects.globalenv.get("print")
stats = importr('stats')
grdevices = importr('grDevices')
base = importr('base')

import math, datetime
import rpy2.robjects.lib.ggplot2 as ggplot2
import rpy2.robjects as robjects
from rpy2.robjects.packages import importr


def index(request):
    latest_stock_list = Stock.objects.all().order_by('-start_date')[:5]
    context = {'latest_stock_list': latest_stock_list}
    return render(request, 'stocks/index.html', context)


def detail(request, stock_id):
    try:
        stock = Stock.objects.get(pk=stock_id)
    except Stock.DoesNotExist:
        raise Http404
    return render(request, 'stocks/detail.html', {'stock': stock})


def plot(request, stock_id):
    stock = get_object_or_404(Stock, pk=stock_id)
    return render(request, 'stocks/plot.html', {'stock': stock})


def retrieve(request):
    stockname = request.POST['stockname']
    q = GoogleIntradayQuote(stockname, 300, 1)
    qlines = q.to_csv().strip().split("\n")
    if not qlines:
        e = "Couldn't find ", stockname, " data"
        return render(request, 'stocks/index.html', {'error_message': e})
    else:
        s = Stock(ticker=q.symbol,
                  start_date=timezone.now() - datetime.timedelta(days=1))
        s.save()
        for tick in q.get_ticks():
            print "tick: ", tick,
            dt = parse_datetime(tick[0])
            p = tick[1]
            print " price: ", p
            s.tick_set.create(time=dt, price=p)
        s.save()

        # tells the R plotting device to write the plot to a file
        f = "static/stocks/images/tmp.png"
        grdevices.png(file=f, width=512, height=512)

        # make a random plot
        rnorm = stats.rnorm
        df = {'value': rnorm(300, mean=0) + rnorm(100, mean=3),
              'other_value': rnorm(300, mean=0) + rnorm(100, mean=3),
              'mean': IntVector([0, ] * 300 + [3, ] * 100)}
        dataf_rnorm = robjects.DataFrame(df)

        gp = ggplot2.ggplot(dataf_rnorm)
        pp = gp + \
            ggplot2.aes_string(x='value', y='other_value') + \
            ggplot2.geom_bin2d() + \
            ggplot2.opts(title='geom_bin2d')
        pp.plot()

        grdevices.dev_off()

        context = {'stockname': stockname,
                   'history': qlines}
        return render(request, 'stocks/retrieve.html', context)


# def vote(request, poll_id):
#     p = get_object_or_404(Poll, pk=poll_id)
#     try:
#         selected_choice = p.choice_set.get(pk=request.POST['choice'])
#     except (KeyError, Choice.DoesNotExist):
#         # Redisplay the poll voting form.
#         return render(request, 'polls/detail.html', {
#             'poll': p,
#             'error_message': "You didn't select a choice.",
#         })
#     else:
#         selected_choice.votes += 1
#         selected_choice.save()
#         # Always return an HttpResponseRedirect after successfully dealing
#         # with POST data. This prevents data from being posted twice if a
#         # user hits the Back button.
#         return HttpResponseRedirect(reverse('polls:results', args=(p.id,)))

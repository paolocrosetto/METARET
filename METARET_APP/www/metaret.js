$(document).on('click', '.metaret-nav-card', function(e) {
  e.preventDefault();
  var t = $(this).attr('data-target-tab');
  $('a.item[data-tab="shiny-tab-' + t + '"]').first().click();
});

var metaretLastTab = null;
function metaretSyncChrome() {
  var active = document.querySelector('.ui.tab.tab-pane.active');
  var tab = active && active.getAttribute('data-tab');
  if (!tab || tab === metaretLastTab) return;
  metaretLastTab = tab;
  document.body.classList.toggle('metaret-nav-collapsed',
                                 tab === 'shiny-tab-tab_homepage');
}

var metaretResizeTimer;
function metaretRefreshOutputs() {
  clearTimeout(metaretResizeTimer);
  metaretResizeTimer = setTimeout(function() {
    window.dispatchEvent(new Event('resize'));
  }, 80);
}

function metaretReportViewport() {
  if (window.Shiny && Shiny.setInputValue) {
    Shiny.setInputValue('metaret_viewport_h', window.innerHeight);
  }
}

$(function() {
  metaretReportViewport();
  $(document).on('shiny:connected', metaretReportViewport);
  var viewportTimer;
  window.addEventListener('resize', function() {
    clearTimeout(viewportTimer);
    viewportTimer = setTimeout(metaretReportViewport, 150);
  });

  var observer = new MutationObserver(function() {
    metaretSyncChrome();
    metaretRefreshOutputs();
  });
  document.querySelectorAll('.ui.tab').forEach(function(pane) {
    observer.observe(pane, { attributes: true, attributeFilter: ['class'] });
  });

  metaretSyncChrome();

  var burger = document.querySelector('a.item > i.sidebar.icon');
  if (burger && burger.parentElement) {
    burger.parentElement.addEventListener('click', function(e) {
      e.preventDefault();
      e.stopPropagation();
      document.body.classList.toggle('metaret-nav-collapsed');
      metaretRefreshOutputs();
    }, true);
  }
});

var METARET_LABEL_GAP = 3;
var metaretLabelTimer = null;

function metaretDeclutterMapLabels() {
  var labels = document.querySelectorAll('.metaret-country-label');
  var kept = [];

  labels.forEach(function(el) { el.classList.remove('metaret-label-hidden'); });

  labels.forEach(function(el) {
    var r = el.getBoundingClientRect();
    if (!r.width) { return; }

    var clash = kept.some(function(k) {
      return !(r.right  + METARET_LABEL_GAP < k.left ||
               r.left   - METARET_LABEL_GAP > k.right ||
               r.bottom + METARET_LABEL_GAP < k.top ||
               r.top    - METARET_LABEL_GAP > k.bottom);
    });

    if (clash) { el.classList.add('metaret-label-hidden'); }
    else       { kept.push(r); }
  });
}

function metaretScheduleDeclutter() {
  clearTimeout(metaretLabelTimer);
  metaretLabelTimer = setTimeout(metaretDeclutterMapLabels, 150);
}

function metaretWatchMapLabels() {
  var host = document.getElementById('map_crra');
  if (!host) { return; }

  new MutationObserver(function(records) {
    var fromMap = records.some(function(r) {
      return !(r.target.classList &&
               r.target.classList.contains('metaret-country-label'));
    });
    if (fromMap) { metaretScheduleDeclutter(); }
  }).observe(host, {
    attributes: true, attributeFilter: ['style', 'class'],
    childList: true, subtree: true
  });
}

document.addEventListener('DOMContentLoaded', metaretWatchMapLabels);

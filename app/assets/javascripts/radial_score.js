$(document).ajaxComplete(function(){
  $('.progress-pie-chart').each(function(index, item){
    var $ppc = $(item);
    var percent = parseInt($ppc.data('percent'));
    var deg = 360*percent/100;
    if (percent > 50) {
      $ppc.addClass('gt-50');
    }
    $(item).find('.ppc-progress-fill').css('transform','rotate('+ deg +'deg)');
    $(item).find('.ppc-percents span').html(percent+'%');
  });

  $(".decline-trigger").on('click', function(e){
    e.preventDefault();
    var selector = $(this).attr("target");
    $(selector).removeClass("hidden");
  });

});

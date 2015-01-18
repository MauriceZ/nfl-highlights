// page:load is for turbolinks event
$(document).on('ready page:load', function() {

    $('a[href$=".png"], a[href$=".jpg"], a[href$=".jpeg"]').addClass("image");

    var $vidContainer = $('#vid-container'),
        $video = $('#vid-player'),
        $imgContainer = $('#img-container'),
        $img = $('#img-elem'),
        $loading = $('.loading'),
        $media = $('.media'),
        currentUrl = "";

    function displayVideo($a) {
        var url = $a.attr('href');

        if (currentUrl != url) {
            $media.hide();
            $loading.show();
            currentUrl = "";
            playVideo($a);
        }
        else {
            $vidContainer.toggle();
            $loading.hide();
            $video[0].paused ? $video[0].play() : $video[0].pause();
        }
    }

    function playVideo($a) {
        $('#mp4-source').attr('src', $a.data('mp4'));
        $('#webm-source').attr('src', $a.data('webm'));

        $video[0].load();
        $video[0].addEventListener("canplaythrough", function(e) {
            currentUrl = $a.attr('href');;
            center($vidContainer);

            setTimeout(function() { 
                $vidContainer.show(); 
                $loading.hide();
            }, 200);

            // remove event
            e.target.removeEventListener(e.type, arguments.callee);
        }, false);
    }

    function displayImage(url) {
        if (currentUrl != url) {
            $media.hide();
            $loading.show();
            $img.attr('src', url);
            currentUrl = url;

            setTimeout(function(){  // Set timeout is needed so that the img element is loaded
                center($imgContainer);
                $imgContainer.show();
                $loading.hide();
            }, 200);
        }
        else {
            $imgContainer.toggle();
            $loading.hide();
        }   
    }

    function center($elem) {
        $elem.children().removeAttr('style');

        var winWidth = $(window).outerWidth(),
            winHeight = $(window).outerHeight();

        if ($elem.height() > winHeight - 70) {
            $elem.children('img, video').height(winHeight - 70);
        }

        var elemWidth = $elem.width(),
            elemHeight = $elem.height();

        $elem.css({
            "left": (winWidth-elemWidth)/2,
            "top": (winHeight-elemHeight)/2,
        });
    }

    /* Events */

    $('body').on('keydown', function(e){
        if (e.keyCode == 27) {
            $media.hide();
            $loading.hide();
            $video[0].pause();
        }
    });

    $(document).on('click', function(e){
        e.stopPropagation();
        $media.hide();
        $loading.hide();
        $video[0].pause();
    });

    $('.md a').on('click', function(e){
        e.preventDefault();
        e.stopImmediatePropagation();
        $a = $(this);

        var url = $a.attr('href')

        if ($a.data('mp4')) { // Is video
            displayVideo($(this));
        }
        else if (url.indexOf(".jpg") > -1 || url.indexOf(".png") > -1 || url.indexOf(".jpeg") > -1) { // Is image
            displayImage(url);
        }
        else {
            window.open(url);
        }
    });

});

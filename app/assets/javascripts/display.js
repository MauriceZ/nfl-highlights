// Page:load is for turbolinks event
$(document).on('ready page:load', function() {

    $('a[href$=".png"], a[href$=".jpg"], a[href$=".jpeg"]').addClass("image");

    var $display = $('#display');
    var $vidElem;
    var $loading = $('.loading');
    var currentUrl;

    $('body').on('keydown', function(e){
        if (e.keyCode == 27) {
            $display.hide();
            $loading.hide();
            if ($vidElem)
                $vidElem.pause();
        }
    });

    $(document).on('click', function(e){
        e.stopPropagation();
        $display.hide();
        $loading.hide();
        if ($vidElem)
            $vidElem.pause();
    });

    $('.md a').on('click', function(e){
        e.preventDefault();
        e.stopImmediatePropagation();

        var url = $(this).attr('href')

        if (url.indexOf("gfycat.com") > -1 || url.indexOf(".gifv") > -1) {
            displayVideo($(this));
        }
        else if (isImage(url)) {
            displayImage(url);
        }
        else {
            window.open(url);
        }
    });

    function displayVideo($a) {
        $loading.show();
        var url = $a.attr('href');

        if (currentUrl != url) {
            currentUrl = url;
            if ($vidElem !== undefined) {
                $vidElem.remove();
            }
            $vidElem = createVideoElem($a);
            $display.html($vidElem)
        }
        else {
            $display.toggle();
            $loading.hide();
            $vidElem.paused ? $vidElem.play() : $vidElem.pause();
        }
    };

    function createVideoElem($a) {
        $vidElem = document.createElement('video');
        $vidElem.autoplay = true;
        $vidElem.loop = true;
        $vidElem.controls = false;

        var url = $a.attr('href');

        if (url.indexOf(".gifv") > -1) {
            [".mp4", ".webm"].forEach(function(type) {
                var source = document.createElement('source');
                var reg = /(https?:.+imgur.com\/\w+)\.gifv/;
                source.src = reg.exec(url)[1] + type;
                $vidElem.appendChild(source);
            });
        }
        else {
            var hasSize = url.indexOf("giant.gfycat.com") > -1 || url.indexOf("fat.gfycat.com") > -1 || url.indexOf("zippy.gfycat.com") > -1;

            if (hasSize) {
                var source = document.createElement('source');
                var reg = /https?:.+gfycat.com\/\w+/;
                source.src = reg.exec(url)[1];

                $vidElem.appendChild(source);
            }
            else {
               [{ size: $a.data('mp4size'), type: '.mp4' }, { size: $a.data('webmsize'), type: '.webm' }].forEach(function(gfy) {
                   var source = document.createElement('source');
                   var reg = /https?:.+gfycat.com\/(\w+)/;
                   source.src = "http://" + gfy['size'] + ".gfycat.com/" + reg.exec(url)[1] + gfy['type'];

                   $vidElem.appendChild(source);
               });  
            }
        }

        $vidElem.addEventListener("canplaythrough", function() {
            center($display);
            setTimeout(function() { 
                $display.show(); 
                $loading.hide();
            }, 200);
        }, false);

        return $vidElem;
    }

    function displayImage(url) {
        if (currentUrl != url) {
            $display.hide();
            $loading.show();
            $display.html("<img src='" + url + "'>");
            currentUrl = url;

            setTimeout(function(){  // Set timeout is needed so that the img element is loaded
                center($display);
                $display.show();
                $loading.hide();
            }, 200);
        }
        else {
            $display.toggle();
            $loading.hide();
        }
        
    }

    function isImage(url) {
        var isImage = url.indexOf(".jpg") > -1 || url.indexOf(".png") > -1 || url.indexOf(".jpeg") > -1;
        return isImage;
    }

    function center($elem) {
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

});

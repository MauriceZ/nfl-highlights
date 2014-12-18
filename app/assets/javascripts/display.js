$(function(){

$('a[href$=".png"], a[href$=".jpg"], a[href$=".jpeg"]').addClass("image");

var $display = $('#display');
var $vidElem;
var $gears = $('.uil-gears');
var currentUrl;

$('body').on('keydown', function(e){
    if (e.keyCode == 27) {
        $display.hide();
        $gears.hide();
        if ($vidElem)
            $vidElem.pause();
    }
});

$(document).on('click', function(e){
    e.stopPropagation();
    $display.hide();
    $gears.hide();
    if ($vidElem)
        $vidElem.pause();
});

$('.md a').on('click', function(e){
    e.preventDefault();
    e.stopImmediatePropagation();

    var url = $(this).attr('href')

    if (url.indexOf("gfycat") > -1) {
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
    $gears.show();
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
        $gears.hide();
        $vidElem.paused ? $vidElem.play() : $vidElem.pause();
    }
};

function createVideoElem($a) {
    $vidElem = document.createElement('video');
    $vidElem.autoplay = true;
    $vidElem.loop = true;
    $vidElem.controls = false;

    var url = $a.attr('href');

    [{ size: $a.data('mp4size'), type: '.mp4' }, { size: $a.data('webmsize'), type: '.webm' }].forEach(function(gfy) {
        var source = document.createElement('source');
        var src = url.replace('www.', '').replace('gfycat', gfy['size'] + '.gfycat') + gfy['type'];
        source.src = src;
        $vidElem.appendChild(source);
    });

    $vidElem.addEventListener("loadeddata", function() {
        center($display);
        setTimeout(function() { 
            $display.show(); 
            $gears.hide();
        }, 10);
    }, false);

    return $vidElem;
}

function displayImage(url) {
    if (currentUrl != url) {
        $display.hide();
        $gears.show();
        $display.html("<img src='" + url + "'>");
        currentUrl = url;

        setTimeout(function(){  // Set timeout is needed so that the img element is loaded
            center($display);
            $display.show();
            $gears.hide();
        }, 200);
    }
    else {
        $display.toggle();
        $gears.hide();
    }
    
}

function isImage(url) {
    var imageIndex = url.indexOf(".jpg") + url.indexOf(".png") + url.indexOf(".jpeg");
    if (imageIndex > -3)
        return true;
    return false;
}

function center($elem) {
    var winWidth = $(window).outerWidth(),
        winHeight = $(window).outerHeight();

    if ($elem.height() > winHeight - 40) {
        $elem.children('img').height(winHeight - 40);
    }

    var elemWidth = $elem.width(),
        elemHeight = $elem.height();

    $elem.css({
        "left": (winWidth-elemWidth)/2,
        "top": (winHeight-elemHeight)/2,
    });
}

});

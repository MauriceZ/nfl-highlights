$(function(){

var $display = $('#display');
var vidElem;
var $gears = $('.uil-gears');

$('body').on('keydown', function(e){
    if (e.keyCode == 27) {
        $display.hide();
        $gears.hide();
        if (vidElem)
            vidElem.pause();
    }
});

$(document).on('click', function(e){
    e.stopPropagation();
    $display.hide();
    $gears.hide();
    if (vidElem)
        vidElem.pause();
});

$('.md a').on('click', function(e){
    e.preventDefault();
    e.stopImmediatePropagation();

    
    var url = $(this).attr('href')

    if (url.indexOf("gfycat") > -1) {
        displayVideo(url);
    }
    else if (isImage(url)) {
        $display.hide();
        displayImage(url);
    }
    else {
        window.open(url);
    }
});

function displayVideo(href) {
    $gears.show();
    var currentHref = $display.data('link');

    if (currentHref != href) {
        $display.data('link', href);
        if (vidElem !== undefined) {
            vidElem.remove();
        }
        vidElem = createVideoElem(href);
        $display.html(vidElem)
    } else {
        $display.show();
        $gears.hide();
        vidElem.play();
    }
};

function createVideoElem(href) {
    var vidElem = document.createElement('video');
    vidElem.autoplay = true;
    vidElem.loop = true;
    vidElem.controls = false;

    /* For Safari */
    var source = document.createElement('source');
    var src = href.replace('www.', '').replace('gfycat', 'giant.gfycat') + '.mp4';
    source.src = src;
    vidElem.appendChild(source);

    ['fat', 'zippy', 'giant'].forEach(function(sizeName) {
        var source = document.createElement('source');
        var src = href.replace('www.', '').replace('gfycat', sizeName + '.gfycat') + '.webm';
        source.src = src;
        vidElem.appendChild(source);
    });

    vidElem.addEventListener("loadeddata", function() {
        center($display);
        $display.show();
        $gears.hide();
    }, false);

    return vidElem;
}

function displayImage(url) {
    $gears.show();
    $display.html("<img src='" + url + "'>");
    $display.data('link', url);

    setTimeout(function(){  // Set timeout is needed so that the img element is loaded
        center($display);
        $display.show();
        $gears.hide();
    }, 200);
}

function isImage(url) {
    var type = url.substr(url.length - 4);
    if (type == ".jpg" || type == ".png")
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

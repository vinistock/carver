(function () {
    "use strict";
    $(document).ready(setupMyPage);

    function setupMyPage () {
      $("#my-id").addClass("blue");
      $("#my-other-id").removeClass("green");
      $("#yet-one-more").toggleClass("visible-xs");
      $("#id").className = "italic";
      $("#more-ids").attr("font-weight", "bold");
      $("#more-and-more-ids").attr('font-size', "24px");
      $("#simple-css").css("background-color", "yellow");
      $("#complex-css").css({
        "border-color": "black",
        'padding-left': '5px'
      });
    }
})();

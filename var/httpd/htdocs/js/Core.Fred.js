// --
// Core.Fred.js - Generic Fred functions
// Copyright (C) 2001-2013 OTRS AG, http://otrs.org/
// --
// This software comes with ABSOLUTELY NO WARRANTY. For details, see
// the enclosed file COPYING for license information (AGPL). If you
// did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
// --

"use strict";

var Core = Core || {};
Core.Fred = Core.Fred || {};

/**
 * @namespace
 * @description
 *      This namespace contains all logic for Fred
 */
Core.Fred = (function (TargetNS) {

    /**
     * @function
     * @return nothing.
     * @description
     *      This function inits generic fred functions
     */
    TargetNS.Init = function () {

        // Toolbar items
        $('.FredSearch').bind('click', function() {
            $(this).closest('.DevelFredBox').find('.FredQuickSearch').toggle();
        });
        $('.FredMinimize').bind('click', function() {
            $(this).closest('.DevelFredBox').find('.DevelFredBoxContent').slideToggle('fast');
        });
        $('.FredClose').bind('click', function() {
            $(this).closest('.DevelFredBox').remove();
        });

        // empty the search field
        $('.FredQuickSearch i').bind('click', function() {
            $(this).prev('input').val('').trigger('keydown');
        });

        // register the table filter on the quicksearch fields
        $('.FredQuickSearch input').each(function() {
            Core.UI.Table.InitTableFilter($(this), $(this).closest('.DevelFredBox').find('.FredTableDefault'));
        });

        // register new popup profile as needed by fred
        Core.UI.Popup.ProfileAdd('FredSettings', {
            WindowURLParams: "dependent=yes,location=no,menubar=no,resizable=yes,scrollbars=yes,status=no,toolbar=no",
            Left:            100,
            Top:             100,
            Width:           400,
            Height:          470
        });

        // open the settings popup
        $('.FredSettings').bind('click', function() {
            Core.UI.Popup.OpenPopup($(this).data('url'), 'FredSettings', 'FredSettings');
        });

        // SQL log: Show bind parameters on click of 'show' link
        $('.ShowBindParameters').bind('click', function() {
            $(this).next('.Hidden').toggle();
            return false;
        });

        $('.FredSettingsLink').bind('click', function() {
            window.close();
        });

        // make the fred box draggable
        $('#DevelFredContainer').draggable({
            handle: 'h1',
            stop: function(event, ui) {
                var Top = ui.offset.top,
                    Left = ui.offset.left;

                if (window && window.localStorage !== undefined) {
                    window.localStorage.FRED_console_left = Left;
                    window.localStorage.FRED_console_top  = Top;
                }
            }
        });

        // save fred's window position
        (function(){
            if (window && window.localStorage !== undefined && window.localStorage.FRED_console_left && window.localStorage.FRED_console_top) {

                var SavedLeft  = window.localStorage.FRED_console_left,
                    SavedTop   = window.localStorage.FRED_console_top,
                    FredWidth  = $('#DevelFredContainer').width(),
                    FredHeight = $('#DevelFredContainer').height();

                if (SavedLeft > $('body').width()) {
                    SavedLeft = $('body').width() - FredWidth;
                }
                if (SavedTop > $('body').height()) {
                    SavedTop = $('body').height() - FredHeight;
                }

                if (SavedLeft && SavedTop) {
                    $('#DevelFredContainer').css('left', SavedLeft + 'px');
                    $('#DevelFredContainer').css('top', SavedTop + 'px');
                }
            }
        }());
    };

    TargetNS.Init();

    return TargetNS;
}(Core.Fred.JSLint || {}));
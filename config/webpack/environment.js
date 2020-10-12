const { environment } = require('@rails/webpacker')

const webpack = require('webpack');

environment.plugins.prepend(
    "Provide",
    new webpack.ProvidePlugin({
        $: "jquery",
        jQuery: "jquery",
        jquery: "jquery",
        "window.Tether": "tether",
        Popper: ["popper.js", "default"] // for Bootstrap 4
    })
);

const config = environment.toWebpackConfig();

config.resolve.alias = {
    jquery: 'jquery/src/jquery'
};

module.exports = environment

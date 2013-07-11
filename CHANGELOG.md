## v0.0.6:

* Use nginx user and group attribute for template owner.
* [#4] Add ssl support.
* Allow options to use Hash or Array.

## v0.0.7:

* Use nginx binary attribute for nginx location.

## v0.0.8:

* removed available_sites_repo since we are integrating more with nginx cookbook
* removed enabled_sites_repo since we are integrating more with nginx cookbook
* added nginx_conf_options function to handle template configuration

## v0.0.9:

* Added site_type to LWRP to manually set dynamic vs static sites and updated docs.

## v0.1.0:

* Added single upstream to LWRP.

## v0.1.1:

* Allow for an array of server_name attributes.
* conf_name attribute added.  Define the conf_name independently of the server_name.

## v0.2:

* Fixed ssl creation issues.
* Update listen resource to allow for arrays.

## v0.2.1:

* removed explicit 443 listen port.

## v0.2.2:

* updated default recipe to actually mimic LWRP reources.
exhibit_namespace = function (objects, name, path, doc, parent) {
    # Skip one parent environment because this module is hooked into the chain
    # between the calling environment and its ancestor, thus sitting in its
    # local object search path.

    env = list2env(objects, parent = parent.env(parent))
    module_attr(env, 'path') = path
    module_attr(env, 'name') = name
    class = c(if (grepl('^package:', name)) 'package', 'module', 'environment')
    structure(env, name = name, doc = doc, class = class)
}

exhibit_module_namespace = function (namespace, name, parent, export_list) {
    if (is.null(export_list))
        export_list = ls(namespace)
    else {
        # Verify correctness.
        exist = vapply(export_list, exists, logical(1), envir = namespace)
        if (! all(exist))
            stop(sprintf('Non-existent function(s) (%s) specified for import',
                         paste(export_list[! exist], collapse = ', ')))
    }

    exhibit_namespace(mget(export_list, envir = namespace),
                      paste('module', name, sep = ':'),
                      module_path(namespace),
                      attr(namespace, 'doc'),
                      parent)
}

exhibit_package_namespace = function (namespace, name, parent, export_list) {
    objects = sapply(export_list, getExportedValue, ns = namespace, simplify = FALSE)
    exhibit_namespace(objects,
                      paste('package', name, sep = ':'),
                      getNamespaceInfo(namespace, 'path'),
                      NULL,
                      parent)
}

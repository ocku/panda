# Panda

A framework for my upcoming blog.
![image](https://github.com/ocku/panda/assets/147977941/affbfd9b-87dc-4147-88be-bb01c083d517)

## Getting started

### Clone the repo

```sh
git clone https://github.com/ocku/panda.git
```

### Install the dependencies

Panda requires [Make](<https://en.wikipedia.org/wiki/Make_(software)>), [Pandoc](https://pandoc.org/) and [JQ](https://github.com/jqlang/jq) to be present on your system. Make sure they are all installed before proceeding to the next step.

### Make your first post

```sh
make post title="Hello World!"
```

### Build

And that's it! You can build the site with `make -j$(nproc)` and it will compile to `ROOT_OUT_DIR`, which is `.dist` by default.

### Build + Watch

Alternatively, you can use a dev server and the `watch` command to update the build as you code and get live updates.

```sh
# on terminal 1 ------------
watch -n .5 make -j$(nproc)
# on terminal 2 ------------
# you can use your favourite dev server,
# just make sure it's serving .dist
npx serve .dist
```

## Configuration

### Metadata

You can configure the global metadata that all template files have access to by editing the `site.json` file.

### Everything else

Panda is designed to be very simple, so there's no real framework for configuration. You can extend and customise the project as you like by writing your own code.

## File structure

Panda uses 6 directories, each with its own behaviour:

### Templates

The templates directory is used to store your templates. There are three standard templates that must always be present for Panda to work correctly:

- `data.tpl`: Used to render the metadata of a post into JSON.
- `index.html`: Used to create the index pages (along with pagination)
- `post.html`: Used to render posts

These are all used by pandoc when rendering files, so they use the [pandoc template syntax](https://pandoc.org/MANUAL.html#template-syntax). You can extend them as you like.

### Posts

All markdown files in the posts directory are considered by Panda as a file to compile. Each file in this directory should have a title, date and sort parameters, which are automatically created when you call `make post`

Any metadata parameters you add to the post will be accessible within the `post.html` template.

### Static

Everything from the static dir is copied to the `ROOT_OUT_DIR` (`.dist`). File collisions are undefined behaviour, as both files are handled in different parts of the compilation process. Depending on which finishes first, either your static file or your compiled file will be overwritten by the other.

### Filters

This is where the JQ filters live. There are three essential filters needed to make it all work:

- `post.jq`: adds the `path` of the post to its metadata and converts `sort` into a number, to be used by `index.jq`

- `index.jq`: Does the indexing. Orders posts and chunks them into arrays of `length=POSTS_PER_PAGE`, configurable by editing the `Makefile`

- `page.pq`: Grabs one of the chunks generated by `index.jq` at a given index and adds the global metadata from `site.json` to it. This data is then added to a new file, which is later rendered into an index page.

### .data

This is where all the data generated by the above filters is stored. It also acts as a cache to avoid rendering files that have not changed.

`make clean` gets rid of this directory, and `make` generates it automatically.

### .dist

This is where the compiled site goes.

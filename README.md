It's a blag!

## For content editors

All you should need to edit is in the `content/` directory.  There are two types of content:

### Posts

Posts are in the `content/posts` directory.

A Post is an entry in the blog.  It has a publish date, a title, and a body.  You can look at one of the posts in the `content/posts` directory for an example of how to write a post.

The body of posts are processed through [markdown][], which allows you to easily specify things like links, *italics*, and **bold**.

For especially long posts, add the text

    <!--fold-->

somewhere near the middle of the document.  Content above the `<!--fold-->` tag will appear on the homepage, and readers will be able to continue reading by clicking a "Read More" link.

[markdown]: http://daringfireball.net/projects/markdown/

### Pages

Pages are in the `content/pages` directory.

A page is a static piece of content, like the "About Me" page.  It has a title, but no date.

### Links

Links are in `content/links.yml`.  These are the links that will appear in the sidebar, including a link to the homepage, and various pages.  Each link has a `name`, which is the text that will appear in the sidebar, and an `href`, which is the url it goes to.  If a url starts with a `/`, that means it's on the local site.  So if you want to link to a page stored in `content/pages/my-cool-page.md`, you would make a link with an `href` of `/pages/my-cool-page`.

## For designers

All you should need is in the `templates/` directory and the `assets/` directory.

The stylesheet is in `assets/sass/application.sass`, and it uses a stylesheet language called [Sass][].

[sass]: http://sass-lang.com/

The templates are in the `templates/` directory.  They are written in a language called [Haml][].  There are only a few important ones:

- `layout.haml` is the surrounding layout for the page.
- `index.haml` is the homepage.
- `post/header.haml` is shared between the home page and the post page - it displays a header with a date.
- `post.haml` displays a single post.
- `page.haml` displays a single page.

[haml]: http://haml.info/

### Running the server
To run the server, you will need a ruby environment.  I recommend installing via [ry](https://github.com/jayferd/ry).  Once you have that set up, open a terminal and run

```
$ bundle install
$ unicorn
```

Then you can go to `http://localhost:8080/` in your browser to see the site.

## For developers

It's simple enough, you should be able to figure it out :).  Happy hacking.

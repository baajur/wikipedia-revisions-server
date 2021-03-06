FROM pypy:3

# install rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# install revisions downloader
RUN pypy3 -m pip install git+https://github.com/DominicBurkart/wikipedia-revisions.git

# download & cache crates.io registry and project dependencies
RUN mkdir src && cd src && echo 'fn main() {}' > main.rs
ADD Cargo.toml .
RUN /root/.cargo/bin/cargo fetch

# make directories
RUN mkdir /pipes
RUN mkdir /big_dir
RUN mkdir /fast_dir

# add test data
ADD test_data/* test_data/

# add code & compile
ADD src/* src/
RUN chmod +x /src/download
RUN /root/.cargo/bin/cargo test
RUN /root/.cargo/bin/cargo build --release
RUN mv ./target/release/wikipedia-revisions-server ./wikipedia-revisions-server
RUN rm -r ./target

# set env variables
ENV TERM xterm-256color
ENV RUST_BACKTRACE=1

ENTRYPOINT ["./wikipedia-revisions-server"]

# example use:
# docker build -t wikipedia-revisions-server . && docker run -it -v /Volumes/doggo:/fast_dir -v /Volumes/burkart-6tb/wiki_revisions:/big_dir wikipedia-revisions-server -d 20200601

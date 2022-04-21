void main() {
		const int fd = open("/proc/self/fd", 0);
		puts(iota(fd));
}

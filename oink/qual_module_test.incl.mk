# see License.txt for copyright and terms of use

# Included makefile for testing just that qual can parse what it
# should.

ifndef QUAL_TEST_MAKEFILE
$(error This makefile should be included in qual_test.incl.mk, not used stand-alone)
endif

.PHONY: qual-module-check
qual-module-check: qual-module-check-misc
qual-module-check: qual-module-check-write-filter
qual-module-check: qual-module-check-access-filter
qual-module-check: qual-module-check-trust-filter

.PHONY: qual-module-check-misc
qual-module-check-misc:
	./qual -o-mod-spec Test/mod_foo_dupl.mod; test $$? -eq 1
	./qual -o-mod-spec foo:Test/mod_foo_dupl.mod; test $$? -eq 1
	./module_make_lattice --mod waga --mod zeeip | \
	  grep 'module_make_lattice modules: waga, zeeip'; test $$? -eq 1
	$(ANNOUNCE_TEST_PASS)

# do a polymorphic analysis
QUALCC_FLAGS += -fq-poly

# do not do an instance-sensitive analysis
QUALCC_FLAGS += -fo-no-instance-sensitive

# FIX: We need to do a global qualifier analysis, so turn this back on
# QUALCC_FLAGS += -fo-report-link-errors

# it is more conservative to turn this off, so I do; FIX: we could
# turn it on if there is no const casting and we are trusting the
# compiler
QUALCC_FLAGS += -fq-no-use-const-subtyping

# make faster by suppressing output
QUALCC_FLAGS += -fq-no-names
QUALCC_FLAGS += -fq-no-explain-errors
QUALCC_FLAGS += -fq-no-name-with-loc

TEST_TOCLEAN += *.filter-good.c *.filter-bad.c

.PHONY: qual-module-check-write-filter
TEST_TOCLEAN += Test/mod_foo_hello_write_good.lattice
TEST_TOCLEAN += Test/mod_foo_hello_write_bad.lattice
qual-module-check-write-filter:
	@echo "$@: good"
	./test_filter -good < Test/mod_write_hello.c \
	  > Test/mod_write_hello.filter-good.c
	./module_make_lattice --write \
          --mod hello --mod foo \
	  > Test/mod_foo_hello_write_good.lattice
	./qual -fq-module-write $(QUALCC_FLAGS) \
	  -q-config Test/mod_foo_hello_write_good.lattice \
	  -o-mod-spec hello:Test/mod_write_hello_good.mod \
	  -o-mod-spec foo:Test/mod_foo.mod \
	  Test/mod_write_hello.filter-good.c Test/mod_lib_foo.c
	@echo "$@: bad"
	./test_filter -bad < Test/mod_write_hello.c \
	  > Test/mod_write_hello.filter-bad.c
	./module_make_lattice --write \
          --mod hello --mod foo \
	  > Test/mod_foo_hello_write_bad.lattice
	./qual -fq-module-write $(QUALCC_FLAGS) \
	  -q-config Test/mod_foo_hello_write_bad.lattice \
	  -o-mod-spec hello:Test/mod_write_hello_bad.mod \
	  -o-mod-spec foo:Test/mod_foo.mod \
	  Test/mod_write_hello.filter-bad.c Test/mod_lib_foo.c; test $$? -eq 32
	$(ANNOUNCE_TEST_PASS)

.PHONY: qual-module-check-access-filter
TEST_TOCLEAN += Test/mod_foo_hello_access_good.lattice
TEST_TOCLEAN += Test/mod_foo_hello_access_bad.lattice
qual-module-check-access-filter:
	@echo "$@: good"
	./test_filter -good < Test/mod_access_hello.c \
	  > Test/mod_access_hello.filter-good.c
	./module_make_lattice --access \
          --mod hello --mod foo \
	  > Test/mod_foo_hello_access_good.lattice
	./qual -fq-module-access $(QUALCC_FLAGS) \
	  -q-config Test/mod_foo_hello_access_good.lattice \
	  -o-mod-spec hello:Test/mod_access_hello_good.mod \
	  -o-mod-spec foo:Test/mod_foo.mod \
	  Test/mod_access_hello.filter-good.c Test/mod_lib_foo.c
	@echo "$@: bad"
	./test_filter -bad < Test/mod_access_hello.c \
	  > Test/mod_access_hello.filter-bad.c
	./module_make_lattice --access \
          --mod hello --mod foo \
	  > Test/mod_foo_hello_access_bad.lattice
	./qual -fq-module-access $(QUALCC_FLAGS) \
	  -q-config Test/mod_foo_hello_access_bad.lattice \
	  -o-mod-spec hello:Test/mod_access_hello_bad.mod \
	  -o-mod-spec foo:Test/mod_foo.mod \
	  Test/mod_access_hello.filter-bad.c Test/mod_lib_foo.c; test $$? -eq 32
	$(ANNOUNCE_TEST_PASS)

.PHONY: qual-module-check-access-lib_foo_simple1
TEST_TOCLEAN += lib_foo_simple1.lattice
qual-module-check-access-lib_foo_simple1:
	@echo "$@"
	./module_make_lattice --access --mod hello --mod foo --mod default \
	  > Test/lib_foo_simple1.lattice
	./qual -q-config Test/lib_foo_simple1.lattice -fq-module-access \
	  $(QUALCC_FLAGS) \
	  -o-mod-spec hello:Test/lib_foo_simple1_hello.mod \
	  -o-mod-spec foo:Test/lib_foo_simple1_foo.mod \
	  -o-mod-default default \
	  Test/lib_foo_simple1.i; test $$? -eq 32
	$(ANNOUNCE_TEST_PASS)

.PHONY: qual-module-check-trust-filter
TEST_TOCLEAN += Test/mod_bar_hello_trust_good.lattice
TEST_TOCLEAN += Test/mod_bar_hello_trust_bad.lattice
qual-module-check-trust-filter:
	@echo "$@: good"
	./test_filter -good < Test/mod_trust_hello.c \
	  > Test/mod_trust_hello.filter-good.c
	./module_make_lattice --trust \
          --mod hello --mod bar \
	  > Test/mod_bar_hello_trust_good.lattice
	./qual -fq-module-trust $(QUALCC_FLAGS) \
	  -q-config Test/mod_bar_hello_trust_good.lattice \
	  -o-mod-spec hello:Test/mod_trust_hello_good.mod \
	  -o-mod-spec bar:Test/mod_bar.mod \
	  Test/mod_trust_hello.filter-good.c Test/mod_trust_bar.c
	@echo "$@: bad"
	./test_filter -bad < Test/mod_trust_hello.c \
	  > Test/mod_trust_hello.filter-bad.c
	./module_make_lattice --trust \
          --mod hello --mod bar \
	  > Test/mod_bar_hello_trust_bad.lattice
	./qual -fq-module-trust $(QUALCC_FLAGS) \
	  -q-config Test/mod_bar_hello_trust_bad.lattice \
	  -o-mod-spec hello:Test/mod_trust_hello_bad.mod \
	  -o-mod-spec bar:Test/mod_bar.mod \
	  Test/mod_trust_hello.filter-bad.c Test/mod_trust_bar.c; test $$? -eq 32
	$(ANNOUNCE_TEST_PASS)

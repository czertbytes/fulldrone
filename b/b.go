package b

import (
	"fmt"
	"time"

	"golang.org/x/net/context"
)

func B() {
	fmt.Println("B")

	context.WithTimeout(context.Background(), 5*time.Second)
}
